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
      libsForQt5.qt5.qtquickcontrols2 # Qt Quick Controls 2 for Qt 5.
      libsForQt5.qt5.qtgraphicaleffects # Graphical effects for Qt 5.
    ];
    services = {
      libinput.enable = true;
      displayManager = {
        sddm = {
          enable = true;
          wayland = {
            enable = true;
            compositor = "kwin";
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
