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
      kdePackages.qtgraphs # Graphical effects for Qt 5.
      kdePackages.qtvirtualkeyboard
      kdePackages.qtsvg
      kdePackages.qtmultimedia
    ];
    services = {
      libinput.enable = true;
      displayManager = {
        defaultSession = "hyprland-uwsm";
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
