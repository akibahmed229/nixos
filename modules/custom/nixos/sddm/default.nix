{ lib, config, pkgs, self, user, ... }:
let
  cfg = config.sddm;
in
{
  options = {
    sddm = {
      enable = lib.mkEnableOption "Enable SDDM";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        layout = "us";
        xkbOptions = "eorsign:e";
        displayManager = {
          sddm.enable = true;
          sddm.settings = {
            General = {
              background = "/home/${user}/.cache/swww/Wallpaper";
            };
          };
          sddm.theme = ''${self.packages.${pkgs.system}.custom_sddm.override  { imgLink = {
          url = "https://raw.githubusercontent.com/akibahmed229/nixos/main/public/wallpaper/nix-wallpaper-nineish-dark-gray.png"; 
          sha256 = "sha256-nhIUtCy/Hb8UbuxXeL3l3FMausjQrnjTVi1B3GkL9B8=";
        };
      }}'';
        };
      };
    };
  };
}

