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
    environment.systemPackages = with pkgs; [
      libsForQt5.qt5.qtgraphicaleffects
      qt6Packages.qtgraphs
      qt6Packages.qtvirtualkeyboard
      qt6Packages.qtsvg
      qt6Packages.qtmultimedia
    ];
    services = {
      libinput.enable = true;
      displayManager = {
        # defaultSession = "hyprland-uwsm";
        sddm = {
          enable = true;
          wayland = {
            enable = true;
          };
          settings.General.DisplayServer = "wayland";
          theme = ''${self.packages.${pkgs.system}.custom_sddm.override {
              imgLink = {
                url = "https://raw.githubusercontent.com/akibahmed229/wallpaper/main/gruv_saturn.png";
                sha256 = "sha256-AKSBdzNhqnHfQNqcjalXDrRV0qPidPrd7o+CV5tdQ98=";
              };
            }}'';
        };
      };
    };
  };
}
