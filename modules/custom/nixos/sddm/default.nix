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
        sddm = {
          enable = true;
          settings = {
            Users = {
              DefaultUser = "Akib";
              RememberLastUser = true;
            };
          };
          theme = ''${self.packages.${pkgs.system}.custom_sddm.override {
              imgLink = {
                url = "https://raw.githubusercontent.com/akibahmed229/wallpaper/main/nixos.png";
                sha256 = "sha256-QcY0x7pE8pKQy3At81/OFl+3CUAbx0K99ZHk85QLSo0=";
              };
            }}'';
        };
      };
    };
  };
}
