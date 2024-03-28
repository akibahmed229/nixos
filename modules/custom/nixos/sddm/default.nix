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
          sddm.theme = ''${self.packages.${pkgs.system}.custom_sddm.override  { 
            imgLink = { 
              url = "https://raw.githubusercontent.com/akibahmed229/nixos/main/public/wallpaper/evening-sky.png"; 
              sha256 = "sha256-fYMzoY3un4qGOSR4DMqVUAFmGGil+wUze31rLLrjcAc=";
            };
          }}'';
        };
      };
    };
  };
}

