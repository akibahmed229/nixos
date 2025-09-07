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
    qt6.qt5compat
    libsForQt5.qtquickcontrols2
    lm_sensors
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
