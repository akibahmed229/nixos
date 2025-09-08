{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  quickshellConfig = "$FLAKE_DIR/modules/predefiend/home-manager/quickshell/quickshell";
  quickshellTarget = "${config.home.homeDirectory}/.config/quickshell";
in {
  home.activation.symlinkQuickshellConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn "${quickshellConfig}" "${quickshellTarget}"
  '';

  home.packages = with pkgs; [
    # Quickshell stuff
    qt6Packages.qt5compat
    libsForQt5.qt5.qtgraphicaleffects
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtstyleplugin-kvantum
    wallust
  ];

  programs.quickshell = {
    enable = true;
    package = inputs.quickshell.packages.${pkgs.system}.default.override {
      withJemalloc = true;
      withQtSvg = true;
      withWayland = true;
      withX11 = false;
      withPipewire = true;
      withPam = true;
      withHyprland = true;
      withI3 = false;
    };
    systemd.enable = true;
  };
}
