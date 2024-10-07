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
    if user == config.setUserName
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
    stateVersion = lib.mkDefault "${config.state-version}"; # Please read the comment before changing.
  };
in {
  options = {
    setUserName = lib.mkOption {
      description = "The user to be created";
      default = "test";
      type = lib.types.str;
    };
    state-version = lib.mkOption {
      description = "State version of home-manager";
      default = "24.11";
      type = lib.types.str;
    };
    desktopEnvironment = lib.mkOption {
      description = "Desktop Environment";
      default = "hyprland";
      type = lib.types.str;
    };
  };

  options.myusers = mkOption {
    type =
      types.listOf
      (types.submodule {
        options = {
          name = mkOption {
            description = "The user to be created";
            type = types.str;
          };
          isNormalUser = mkOption {
            type = types.bool;
            default = true;
          };
          hashedPassword = mkOption {
            type = types.str or null;
            example = "$/kc0mR9DIF03ooxkNHJLjDQbXbFO8lzN3spAWeszws4K1saheHEzIDxI6NNyr3xHyH.VQPHCs0";
            description = "password can be hashed with: nix run nixpkgs#mkpasswd -- -m SHA-512 -s";
          };
          hashedPasswordFile = mkOption {
            type = types.str or null;
            example = "/etc/nixos/secrets/my_secret.nix";
            description = "password can be hashed with: nix run nixpkgs#mkpasswd -- -m SHA-512 -s";
          };
          extraGroups = mkOption {
            type = types.listOf types.str;
          };
          packages = mkOption {
            type = types.listOf types.package;
          };
          shell = mkOption {
            type = types.package;
            default = pkgs.bash;
          };
          homeFile = mkOption {
            default = [];
          };
          enabled = mkOption {
            type = types.bool;
            default = true;
          };
        };
      });
    default = [];
  };

  config = {
    # List of users
    myusers = [
      rec {
        name = config.setUserName;
        isNormalUser = true;
        hashedPasswordFile =
          if (config.sops.secrets."${name}/password/my_secret".path != {})
          then config.sops.secrets."${name}/password/my_secret".path
          else null;
        hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";
        extraGroups = ["networkmanager" "wheel" "systemd-journal" "docker" "video" "audio" "scanner" "libvirtd" "kvm" "disk" "input" "plugdev" "adbusers" "flatpak" "wireshark" "kubernetes" "postgres" "mysql" "openrazer"];
        packages = with pkgs; [wget thunderbird vlc];
        shell = checkUserFun name;
        homeFile =
          map mkRelativeToRoot [
            "home-manager/home.nix" # config of home-manager
            "home-manager/${config.desktopEnvironment}/home.nix"
            "hosts/nixos/desktop/home.nix"
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
        hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";
        extraGroups = ["networkmanager" "wheel" "video" "audio" "scanner" "disk" "input" "flatpak"];
        packages = with pkgs; [wget thunderbird vlc];
        shell = checkUserFun name;
        homeFile =
          map mkRelativeToRoot [
            "home-manager/home.nix" # config of home-manager
            "home-manager/${config.desktopEnvironment}/home.nix"
            "hosts/nixos/desktop/home.nix"
          ]
          ++ [{home = userHome name;}];
        enabled =
          if config.setUserName == "akib"
          then true
          else false;
      }
      rec {
        name = "root";
        isNormalUser = false;
        hashedPasswordFile =
          if (config.setUserName == "akib")
          then config.sops.secrets."akib/password/root_secret".path
          else null;
        hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";
        packages = with pkgs; [neovim wget];
        extraGroups = [];
        shell = checkUserFun name;
        homeFile = [{home = userHome name;}];
        enabled = true;
      }
    ];
  };
}
