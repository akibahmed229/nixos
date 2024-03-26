{ lib, config, pkgs, ... }:
let
  cfg = config.user;
  shell = pkgs.zsh;
  link = [ "/share/zsh" "/tmp" "/home/${cfg.userName}" ];
  checkUserFun = user: if user == "akib" then shell else pkgs.bash;
in
{
  options.myusers = mkOption {
    type = types.listOf
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
            type = types.str;
            example = "$/kc0mR9DIF03ooxkNHJLjDQbXbFO8lzN3spAWeszws4K1saheHEzIDxI6NNyr3xHyH.VQPHCs0";
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
    default = [ ];
  };

  config = {
    myusers = [
      {
        name = "akib";
        isNormalUser = true;
        hashedPassword = "$6$y5qxEUAdhGfuMjTA$7zd9DbLF3hw8BCi.pOGI0BYg2hUTcNnP8FkzJtXfOgBOD9fv8cmBlmbMbiaOTsfeqeLyRgY/XMxkADpBsBa4Z0";
        extraGroups = [ "networkmanager" "wheel" "systemd-journal" "docker" "video" "audio" "scanner" "libvirtd" "kvm" "disk" "input" "plugdev" "adbusers" "flatpak" "plex" ];
        packages = with pkgs; [
          wget
          thunderbird
          vlc
        ];
        shell = checkUserFun "akib";
        enabled = true;
      }
    ];
  };
}
