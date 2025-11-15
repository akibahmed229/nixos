# modules/obs.nix
# Configures OBS Studio with a set of common plugins and optionally enables
# the virtual camera feature using v4l2loopback and Polkit.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.obs;

  defaultPlugins = with pkgs.obs-studio-plugins; [
    wlrobs
    obs-backgroundremoval
    obs-pipewire-audio-capture
    # droidcam-obs # FIXME: broken
  ];
in {
  # --- 1. Define Options ---
  options.nm.obs = {
    enable = mkEnableOption "Enable OBS Studio and specified plugins";

    enableVirtualCam = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enables the virtual camera feature, which requires the v4l2loopback kernel
        module and Polkit to be configured.
      '';
    };

    extraPlugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of additional OBS plugins to include.";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 Main OBS Studio package and plugin wrapping
    environment.systemPackages = [
      (pkgs.wrapOBS {
        plugins = defaultPlugins ++ cfg.extraPlugins;
      })
    ];

    # 2.2 Virtual Camera Setup (requires v4l2loopback and Polkit)
    # Load the v4l2loopback module
    boot = mkIf cfg.enableVirtualCam {
      extraModulePackages = with config.boot.kernelPackages; [
        v4l2loopback # Use pkgs.v4l2loopback instead of the potentially unavailable config.boot.kernelPackages version
      ];
      kernelModules = ["v4l2loopback"];
      extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
      '';
    };

    # Enable Polkit for OBS to access the virtual device
    security.polkit.enable = true;
  };
}
