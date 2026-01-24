{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.hm.quickshell;
in {
  options.hm.quickshell = {
    enable = mkEnableOption "Quickshell configuration with live symlinking";

    srcPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/flake/modules/custom/home-manager/quickshell/config";
      description = "Absolute path to your Quickshell source for live tinkering.";
    };

    package = mkOption {
      type = types.package;
      default = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
        withJemalloc = true;
        withQtSvg = true;
        withWayland = true;
        withPipewire = true;
        withHyprland = true;
      };
      description = "The Quickshell package with custom build overrides.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      qt6Packages.qt5compat
      libsForQt5.qt5.qtgraphicaleffects
      kdePackages.qtbase
      kdePackages.qtdeclarative
      kdePackages.qtstyleplugin-kvantum
      wallust
    ];

    programs.quickshell = {
      enable = true;
      package = cfg.package;
      systemd.enable = true;
    };

    # Live Tinkering: Create a symlink to the physical folder instead of the Nix store
    home.activation.symlinkQuickshellConfig = hm.dag.entryAfter ["writeBoundary"] ''
      targetDir="${config.xdg.configHome}/quickshell"

      # Remove existing file/link if it exists to avoid conflicts
      rm -rf "$targetDir"

      # Create the symlink to your actual dev folder
      ln -sfn "${cfg.srcPath}" "$targetDir"
    '';
  };
}
