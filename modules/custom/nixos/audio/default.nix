{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.nm.audio;
in {
  options = {
    nm.audio = {
      enable = lib.mkEnableOption "Enable audio support";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable RTKit for real-time audio (helps with PipeWire)
    security.rtkit.enable = true;

    # Enable PipeWire for audio/video sharing (required for screen sharing)
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      wireplumber.enable = true;
    };
  };
}
