# Configures the system-wide theming via Stylix, allowing easy theme, font,
# and cursor changes.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.stylix;

  # Default font configurations for a cleaner module
  defaultFonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
    };
    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };
  };
in {
  # --- 0. Conditional Imports ---
  # imports = [
  #   # Assumes 'stylix' is an input defined in your flake.nix
  #   inputs.stylix.nixosModules.stylix
  # ];

  # --- 1. Define Options ---
  options.nm.stylix = {
    enable = mkEnableOption "Enable and configure the Stylix system theming solution.";

    themeScheme = mkOption {
      type = types.path;
      description = ''
        The Base16 scheme name (e.g., 'gruvbox-dark-soft').
        If using a custom scheme file (like your original config),
        provide the full path: e.g., /path/to/my-custom-theme.yaml
      '';
    };

    # Cursor Configuration
    cursor = {
      package = mkOption {
        type = types.package;
        default = pkgs.bibata-cursors;
        description = "Package providing the cursor theme.";
      };
      name = mkOption {
        type = types.str;
        default = "Bibata-Modern-Classic";
        description = "Name of the cursor theme.";
      };
      size = mkOption {
        type = types.int;
        default = 24;
        description = "Size of the cursor.";
      };
    };

    # Font Configuration
    fonts = mkOption {
      type = types.attrsOf types.unspecified;
      default =
        defaultFonts
        // {
          sizes = {
            applications = 10;
            terminal = 11;
            desktop = 10;
            popups = 14;
          };
        };
      description = "Configuration for monospace, sansSerif, serif fonts and their sizes.";
    };

    # Integration Targets (Now a freeform set to allow upstream overrides)
    targets = mkOption {
      type = types.attrsOf types.unspecified;
      default = {
        gtk.enable = true;
        qt.enable = true;
        gnome.enable = true;
        grub.enable = true;
        console.enable = true;
        nixvim = {
          enable = true;
          # Retain original deep setting for NixVim
          transparentBackground.main = true;
        };
      };
      description = "Integration targets for Stylix. You can override any nested option here, e.g., targets.gnome.enable = false.";
    };

    # Other settings
    polarity = mkOption {
      type = types.enum ["light" "dark" "either"];
      default = "dark";
      description = "Color polarity preference (light, dark, or either).";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = cfg.themeScheme;

      # Disable Home-Manager integration
      homeManagerIntegration.autoImport = false;
      homeManagerIntegration.followSystem = false;

      # Cursor Configuration
      cursor = {
        package = cfg.cursor.package;
        name = cfg.cursor.name;
        size = cfg.cursor.size;
      };

      # Fonts Configuration
      fonts = cfg.fonts;

      # Targets Configuration (Directly assign the full configuration set)
      targets = cfg.targets;

      # Opacity (Retain original hardcoded opacity)
      opacity = {
        applications = 1.0;
        terminal = 1.0;
        desktop = 1.0;
        popups = 1.0;
      };

      # Polarity
      polarity = cfg.polarity;
    };
  };
}
