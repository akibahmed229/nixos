{
  pkgs,
  lib,
  config,
  ...
}:
with lib; {
  # ── 1. OPTIONS ───────────────────────────────────────────────────────────────
  # (This section is already correct, no changes needed)
  options.nm.specialisation = {
    enable = mkEnableOption "Enable specialisation";
    specs = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "this specialisation" // {default = true;};
          description = mkOption {
            type = types.str;
            default = "No description provided.";
            description = "A short description of what this specialisation is for.";
          };
          configuration = mkOption {
            type = types.attrs;
            default = {};
            description = "The actual NixOS configuration for this specialisation.";
          };
        };
      });
      default = {};
      description = "Attribute set of all available NixOS specialisations.";
    };
  };

  /*

  # Example Usage

  let
    # My custom lib helper functions
    inherit (self.lib) mkImport mkRelativeToRoot;
    predefinedPath = mkRelativeToRoot "modules/predefiend/nixos";
  in
  {
    # Define ALL your specialisations in this one block
    nm.specialisation = {
        enable = true;

        specs = {
        "DevOPS" = {
          description = "Tools for Kubernetes, Docker, and CI/CD.";
          configuration = {
            imports = mkImport {
              path = predefinedPath;
              ListOfPrograms = ["kubernetes"];
            };
          };
        };

        "Gaming" = {
          description = "Enables Steam, Lutris, and performance tweaks for gaming.";
          configuration = {
            imports = mkImport {
              path = predefinedPath;
              ListOfPrograms = ["gaming"];
            };
          };
        };

        "Hyprland" = {
          description = "A minimal, tiling Wayland compositor environment.";
          configuration = {
            imports = map mkRelativeToRoot [ "home-manager/hyprland" ];
            home-manager.users.${user} = {
              imports = map mkRelativeToRoot [ "home-manager/hyprland/home.nix" ];
            };
          };
        };

        "Niri" = {
          description = "A scrollable-tiling Wayland compositor inspired by PaperWM.";
          configuration = {
            imports = map mkRelativeToRoot [ "home-manager/niri" ];
            home-manager.users.${user} = {
              imports = map mkRelativeToRoot [ "home-manager/niri/home.nix" ];
            };
          };
        };

        # Example of a defined but disabled specialisation
        "Testing" = {
          enable = false; # This won't show up in the boot menu or switch-spec
          description = "A temporary environment for testing new packages.";
          configuration = {
            environment.systemPackages = [ pkgs.btop ];
          };
        };
      };
    };
  }
  */

  # ── 2. CONFIGURATION ─────────────────────────────────────────────────────────
  config =
    # --- CHANGE #1: Move the `let` block inside `config` to delay evaluation ---
    let
      cfg = config.nm.specialisation;
      enabledSpecs = attrNames (filterAttrs (name: spec: spec.enable) cfg.specs);

      # --- CHANGE #2: Explicitly format the list into a space-separated string ---
      enabledSpecsString = concatStringsSep " " enabledSpecs;
    in
      lib.mkIf cfg.enable {
        specialisation = mapAttrs (name: spec: {
          inherit (spec) configuration;
        }) (filterAttrs (name: spec: spec.enable) cfg.specs);

        environment.sessionVariables = {
          SPECIALISATION = config.specialisation.name or "base";
        };

        environment.systemPackages = [
          (pkgs.writeShellScriptBin "switch-spec" ''
            #!''${pkgs.bash}/bin/bash
            set -euo pipefail

            # Create a bash array from the space-separated string
            AVAILABLE_SPECS=(${enabledSpecsString})

            usage() {
              echo "Usage: switch-spec <specialisation>"
              echo ""
              echo "Available specialisations:"
              # Use "''${!AVAILABLE_SPECS[@]}" if the list is empty, to avoid unbound variable error
              if [ ''${#AVAILABLE_SPECS[@]} -eq 0 ]; then
                echo "  (None defined)"
              else
                for spec in "''${AVAILABLE_SPECS[@]}"; do
                  echo "  - $spec"
                done
              fi
              exit 1
            }

            # (The rest of the script is the same)
            if [ $# -ne 1 ]; then
              usage
            fi

            TARGET_SPEC="$1"
            VALID=false

            for spec in "''${AVAILABLE_SPECS[@]}"; do
              if [[ "$spec" == "$TARGET_SPEC" ]]; then
                VALID=true
                break
              fi
            done

            if ! $VALID; then
              echo "Error: '$TARGET_SPEC' is not a valid specialisation."
              usage
            fi

            echo "Switching to specialisation: $TARGET_SPEC"
            sudo -E /nix/var/nix/profiles/system/specialisation/$TARGET_SPEC/bin/switch-to-configuration switch
          '')
        ];
      };
}
