{
  lib,
  config,
  pkgs,
  self,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (self.lib) mkScanPath mkRelativeToRoot;

  # Home-manager defaults per user
  userHome = name: {
    username = lib.mkDefault "${name}";
    homeDirectory = lib.mkDefault "/home/${name}";
    stateVersion = lib.mkDefault "${config.setUser.state-version}";
  };

  # Load all user modules from the current directory
  fileContents = map (path:
    import path {
      inherit pkgs config mkRelativeToRoot;
      inherit (config.setUser) desktopEnvironment hostname;

      inherit userHome;
    })
  (mkScanPath ./.);
in {
  # Define a setUser option to configure main user settings
  options.setUser = mkOption {
    type = types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "test";
          description = "The main user to be created";
        };
        state-version = lib.mkOption {
          type = lib.types.str;
          default = "25.05";
          description = "State version of home-manager";
        };
        desktopEnvironment = lib.mkOption {
          type = lib.types.str;
          default = "hyprland";
          description = "Desktop Environment of the system";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          default = "desktop";
          description = "Hostname of the system";
        };
        nixosUsers.enable = lib.mkEnableOption "Enable NixOS user configuration";
        homeUsers.enable = lib.mkEnableOption "Enable Home Manager user configuration";
      };
    };
    default = {};
  };

  # Define a list of users options with their configurations
  options.myusers = mkOption {
    type =
      types.listOf
      (types.submodule {
        options = {
          name = mkOption {type = types.str;};
          isNormalUser = mkOption {
            type = types.bool;
            default = true;
          };

          hashedPassword = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "SHA-512 hashed password";
          };
          hashedPasswordFile = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Path to file containing hashed password";
          };

          keys = mkOption {
            type = types.listOf types.str;
            default = [];
          };
          extraGroups = mkOption {
            type = types.listOf types.str;
            default = [];
          };
          packages = mkOption {
            type = types.listOf types.package;
            default = [];
          };
          shell = mkOption {
            type = types.package;
            default = pkgs.bash;
          };

          homeFile = mkOption {
            type = types.anything;
            default = [];
            description = "Home-manager config paths or objects";
          };

          enabledSystemConf = mkOption {
            type = types.bool;
            default = false;
          };
          enabledHomeConf = mkOption {
            type = types.bool;
            default = false;
          };
        };
      });
    default = [];
  };

  config = {
    # Load user configurations from the scanned files
    myusers = fileContents;

    # NixOS system users
    users = lib.mkIf config.setUser.nixosUsers.enable {
      users = builtins.listToAttrs (map (user: {
        inherit (user) name;
        value = {
          inherit (user) hashedPasswordFile hashedPassword extraGroups packages shell isNormalUser;
          openssh.authorizedKeys.keys = user.keys;
        };
      }) (builtins.filter (u: u.enabledSystemConf) config.myusers));
    };

    # Home-manager users
    home-manager = lib.mkIf config.setUser.homeUsers.enable {
      useGlobalPkgs = false;
      users = builtins.listToAttrs (map (user: {
        inherit (user) name;
        value = {imports = user.homeFile;};
      }) (builtins.filter (u: u.enabledHomeConf) config.myusers));
    };
  };
}
