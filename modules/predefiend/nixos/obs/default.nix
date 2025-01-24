{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = [
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture

        # Droidcam is a mobile app (Android, iOS). With Droidcam the mobile device can be used as webcam for a PC.
        # https://droidcam.app/
        droidcam-obs
      ];
    })
  ];

  # The virtual camera requires the v4l2loopback kernel module to be installed, a loopback device configured,
  # and polkit enabled so OBS can access the virtual device:
  boot = {
    # Virtual cam settings: see https://wiki.nixos.org/wiki/OBS_Studio#Using_the_Virtual_Camera
    extraModulePackages = with config.boot.kernelPackages; [
      # v4l2loopback # FIXME: currently broken
    ];
    kernelModules = ["v4l2loopback"];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
  };
  security.polkit.enable = true;
}
