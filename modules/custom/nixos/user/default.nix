{
  lib,
  config,
  pkgs,
  self,
  ...
}:
with lib; let
  inherit (self.lib) mkScanImportPath mkRelativeToRoot;
in {
  # ── Top-level knobs for per-machine defaults (desktop env, hostname, etc.)
  options.nm.setUser = mkOption {
    type = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          default = "test";
          description = "Primary user name";
        };
        usersPath = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path for list of user modules (./user/*/default.nix)";
        };

        # system related info
        system = mkOption {
          type = types.submodule {
            options = {
              state-version = mkOption {
                type = types.str;
                default = "25.11";
                description = "State version of your system";
              };
              desktopEnvironment = mkOption {
                type = types.str;
                default = "hyprland";
                description = "Default desktop environment";
              };
              name = mkOption {
                type = types.str;
                default = "desktop";
                description = "Host name";
              };
              path = mkOption {
                type = types.str;
                default = "desktop";
                description = "Host name";
              };
            };
          };
        };

        nixosUsers.enable = mkEnableOption "Create NixOS users";
        homeUsers.enable = mkEnableOption "Create Home Manager users";
      };
    };
    default = {};
  };

  # ── Schema for each user attrset imported from ./user/*/default.nix
  options.nm.myusers = mkOption {
    type = types.listOf (types.submodule {
      # 1. Custom options.
      options = {
        homeFile = mkOption {
          type = types.anything;
          default = [];
          description = "HM imports or inline objects";
        };
        enableSystemConf = mkOption {
          type = types.bool;
          default = false;
        };
        enableHomeConf = mkOption {
          type = types.bool;
          default = false;
        };
      };

      # 2. Allow any other attributes to pass through without validation.
      freeformType = types.anything;
    });
    default = [];
  };

  config = let
    cfg = config.nm.setUser;
    path =
      if cfg.usersPath != null
      then cfg.usersPath
      else throw "Please set 'usersPath' in 'setUser' option.";

    # Default HM “home” fragment per user (provided to each user module).
    userHome = name: {
      username = mkDefault name;
      homeDirectory = mkDefault "/home/${name}";
      stateVersion = mkDefault cfg.system.state-version;
    };

    # Import all user files lazily *inside* config, so cfg is available.
    myusers =
      mkScanImportPath {
        inherit config pkgs mkRelativeToRoot;
        inherit (cfg) system;
      }
      path;

    # Small helper to pick only users with a given boolean flag set.
    filterBy = flag: builtins.filter (u: u.${flag}) config.nm.myusers;
  in {
    # Make the imported list visible as the option value (defaults fill in).
    nm.myusers = myusers;

    # NixOS system users
    users = mkIf cfg.nixosUsers.enable {
      # required for password to be set via sops during system activation
      mutableUsers =
        if (config.users.users.${cfg.name}.hashedPasswordFile != null)
        then false
        else true;

      users = builtins.listToAttrs (map
        (u: {
          inherit (u) name;
          value = lib.attrsets.removeAttrs u [
            "homeFile"
            "enableSystemConf"
            "enableHomeConf"
          ];
        })
        (filterBy "enableSystemConf"));
    };

    # Home-Manager users
    home-manager = mkIf (cfg.nixosUsers.enable && cfg.homeUsers.enable) {
      users = builtins.listToAttrs (map
        (u: {
          inherit (u) name;
          value = {
            imports =
              [
                {home = userHome name;}
                (import "${cfg.system.path}/home.nix")
                (import "${cfg.system.path}/${cfg.system.name}/home.nix")
              ]
              ++ u.homeFile;
          };
        })
        (filterBy "enableHomeConf"));
    };
  };
}
