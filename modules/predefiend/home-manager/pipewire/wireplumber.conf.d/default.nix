{config, ...}: let
  wireplumberConfCamera = ".config/wireplumber/wireplumber.conf.d/10-disable-camera.conf";
  wireplumberTargetCamera = "${config.home.homeDirectory}/.config/flake/modules/predefiend/home-manager/pipewire/wireplumber.conf.d/10-disable-camera.conf";
in {
  home.file = {
    # The camera's /dev/video file is kept open (without streaming), sadly causing the camera to be powered on what looks to be most devices.
    # For some reason, this completely nullifies the soc power management on modern laptops and can result in increases from 3W to 8W at idle!
    ${wireplumberConfCamera} = {
      source =
        config.lib.file.mkOutOfStoreSymlink wireplumberTargetCamera; # tells wireplumber to ignore cameras
    };
  };
}
