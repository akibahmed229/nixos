{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.audio;
in {
  options = {
    audio = {
      enable = lib.mkEnableOption "Enable audio support";
    };
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      # wireplumber.enable = true;
    };
  };
}
