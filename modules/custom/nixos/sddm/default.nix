{
  lib,
  config,
  pkgs,
  self,
  ...
}: let
  cfg = config.sddm;
in {
  options = {
    sddm = {
      enable = lib.mkEnableOption "Enable SDDM";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      libinput.enable = true;
      xserver = {
        enable = true;
        xkb.layout = "us";
        xkb.options = "eorsign:e";
      };
      displayManager = {
        sddm.enable = true;
        sddm.theme = ''${self.packages.${pkgs.system}.custom_sddm.override {
            imgLink = {
              url = "https://raw.githubusercontent.com/akibahmed229/nixos/main/public/wallpaper/nix-wallpaper-nineish-dark-gray.png";
              sha256 = "07zl1dlxqh9dav9pibnhr2x1llywwnyphmzcdqaby7dz5js184ly";
            };
          }}'';
      };
    };
  };
}
