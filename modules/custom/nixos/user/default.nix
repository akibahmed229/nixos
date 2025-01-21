/*
Custom module to create users with hashed passwords from secrets
This module will help to manage multiple users with different configurations and packages
*/
{
  lib,
  config,
  pkgs,
  self,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (self.lib) mkRelativeToRoot;

  checkUserFun = user:
    if user == config.setUser.name
    then pkgs.zsh
    else pkgs.bash;

  userHome = name: {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = lib.mkDefault "${name}";
    homeDirectory = lib.mkDefault "/home/${name}";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = lib.mkDefault "${config.setUser.state-version}"; # Please read the comment before changing.
  };
in {
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
        users.enable = lib.mkEnableOption "Enable User's Configuration";
        homeUsers.enable = lib.mkEnableOption "Enable Home User's Configuration";
      };
    };
    default = {};
  };

  options.myusers = mkOption {
    type =
      types.listOf
      (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            example = "akib";
            description = "The user to be created";
          };
          isNormalUser = mkOption {
            type = types.bool;
            default = true;
            description = "Normal user or not";
          };
          hashedPassword = mkOption {
            type = types.nullOr types.str;
            example = "$/kc0mR9DIF03ooxkNHJLjDQbXbFO8lzN3spAWeszws4K1saheHEzIDxI6NNyr3xHyH.VQPHCs0";
            description = "password can be hashed with: nix run nixpkgs#mkpasswd -- -m SHA-512 -s";
          };
          hashedPasswordFile = mkOption {
            type = types.nullOr types.str;
            example = "/etc/nixos/secrets/my_secret.nix";
            description = "password can be hashed with: nix run nixpkgs#mkpasswd -- -m SHA-512 -s";
          };
          keys = mkOption {
            type = types.listOf types.str;
            example = "ssh-ed25519 KKKKC3NzaC1lZDI1NTE5OOOIOn1TJvpzEJxCvW6zAnUDLJF2BYlN+KiaMsuTQ3bH5iy example@gmail.com";
            description = "List of OpenSSH public keys";
          };
          extraGroups = mkOption {
            type = types.listOf types.str;
            example = ["networkmanager" "wheel" "systemd-journal"];
            description = "List of extra groups";
          };
          packages = mkOption {
            type = types.listOf types.package;
            example = "with pkgs; [ vlc thunderbird ]";
            description = "List of packages to be installed";
          };
          shell = mkOption {
            type = types.package;
            default = pkgs.bash;
            example = "pkgs.zsh";
            description = "Shell to be used";
          };
          homeFile = mkOption {
            type = types.anything;
            default = [];
            example = "home-manager/home.nix or {home = username= 'akib';}";
            description = "List of home-manager configuration files or home-manager configuration object";
          };
          enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Enable or disable the user";
          };
        };
      });
    default = [];
  };

  config = {
    # List of users
    myusers = [
      rec {
        inherit (config.setUser) name;
        isNormalUser = true;
        hashedPasswordFile =
          if (config.sops.secrets."${name}/password/my_secret".path != {})
          then config.sops.secrets."${name}/password/my_secret".path
          else null;
        keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjC6HW3e25jpnJ3dAR+rQiAGCCwRjdkyzVvr+hBnFPzspX/PW3kcQT40Lyi9VioDGnQhgmP81jH0osikCtMlFhEL0w7ldNQ4CwspfFTwhxq32NCEIneGe4ICKdI3QPYTlgbwPY5HZ9ADPy8ujmzYFacxji+xbqKQddzIAYF/0P2SVpMUT1FBcGCwJQec6JPBxw0dUxekNTX5atJLv50DtUR6PqIjti+dv6PS1FUWLvxVrCSOExNGTVBGXXHJP0yojnWLZFV8y6jC9/mxlzTj5E8RCH4Cws58cC/mAoRh/QpE74UmXWqLAYMaLxVW8GVGXG93he7GdO5ALPF7Wdv2oOSlTk7lIWV5mPAFZPROLnXFLkubmEFFAA4MMUXoXbdFAGDuulS7AYpG/imiyKnhdaWolPoW3J7AbBS0j/VEi6KmPyjt3XxBJvuxWxyNlHr2cQ/vcZ4jg7Wk5O1OS4akknAq+9UnxuJyDAxelHoNqX8+2RXUx8JWcGI02j2DfuUw50nSe1hmZJh9iqBaEHrQiESfeFf5vRiY9ywxG5iBswSQT3ai+kC2S9oPyxmyxfO7E5s/hy7usorfl5rW0mEaVNW1qnTFXdUhWfSRssqiYi5Pc3tSjOrVppI14PLSODioAS5K09LpncHUrPOWf2ZABTdyPTnWrUEpTtmHCiZdiZWw== user@Akib
"
        ];
        hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";
        extraGroups = ["networkmanager" "wheel" "systemd-journal" "docker" "video" "audio" "scanner" "libvirtd" "kvm" "disk" "input" "plugdev" "adbusers" "flatpak" "wireshark" "kubernetes" "postgres" "mysql" "openrazer"];
        packages = with pkgs; [wget thunderbird vlc];
        shell = checkUserFun name;
        homeFile =
          map mkRelativeToRoot [
            "home-manager/home.nix" # config of home-manager
            "home-manager/${config.setUser.desktopEnvironment}/home.nix"
            "hosts/nixos/${config.setUser.hostname}/home.nix"
          ]
          ++ [{home = userHome name;}];
        enabled = true;
      }

      rec {
        name = "afif";
        isNormalUser = true;
        hashedPasswordFile =
          if (config.sops.secrets."${name}/password/my_secret".path != {})
          then config.sops.secrets."${name}/password/my_secret".path
          else null;
        keys = [];
        hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";
        extraGroups = ["networkmanager" "video" "audio" "scanner" "disk" "input" "flatpak"];
        packages = with pkgs; [wget thunderbird vlc];
        shell = checkUserFun name;
        homeFile =
          map mkRelativeToRoot [
            "home-manager/home.nix" # config of home-manager
            "home-manager/${config.setUser.desktopEnvironment}/home.nix"
            "hosts/nixos/${config.setUser.hostname}/home.nix"
          ]
          ++ [{home = userHome name;}];
        enabled =
          if config.setUser.name == "akib"
          then true
          else false;
      }

      rec {
        name = "root";
        isNormalUser = false;
        hashedPasswordFile =
          if (config.setUser.name == "akib")
          then config.sops.secrets."akib/password/root_secret".path
          else null;
        keys = [];
        hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";
        packages = with pkgs; [neovim wget];
        extraGroups = [];
        shell = checkUserFun name;
        homeFile = [{home = userHome name;}];
        enabled = true;
      }
    ];

    # Nixos User's configuration
    users =
      if config.setUser.users.enable
      then {
        users = builtins.listToAttrs (map (user:
          if user.enabled
          then {
            inherit (user) name;
            value = {
              inherit (user) hashedPasswordFile hashedPassword extraGroups packages shell isNormalUser;
              openssh.authorizedKeys.keys = user.keys;
            };
          }
          else {})
        config.myusers);
      }
      else {};

    # Home User's configuration
    home-manager =
      if config.setUser.homeUsers.enable
      then {
        useGlobalPkgs = false;
        users = builtins.listToAttrs (map (user:
          if user.enabled
          then {
            inherit (user) name;
            value = {
              imports = user.homeFile;
            };
          }
          else {})
        config.myusers);
      }
      else {};
  };
}
