/*
Custom module to create users with hashed passwords from secrets
This module will help to manage multiple users with different configurations and packages
*/
{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;

  checkUserFun = user:
    if user == config.setUserName
    then pkgs.zsh
    else pkgs.bash;
in {
  options.setUserName = lib.mkOption {
    description = "The user to be created";
    default = "user";
    type = lib.types.str;
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
        enabled = true;
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
        enabled = true;
      }
    ];
  };
}
