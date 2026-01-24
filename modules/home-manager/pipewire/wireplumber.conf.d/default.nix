{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.wireplumber;
in {
  options.hm.wireplumber = {
    enable = mkEnableOption "WirePlumber session manager configuration";

    sourcePath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/flake/modules/custom/home-manager/wireplumber/10-disable-camera.conf";
      description = ''
        Absolute path to the WirePlumber configuration file.
        Linked via mkOutOfStoreSymlink for easy editing.
      '';
    };
  };

  # The camera's /dev/video file is kept open (without streaming), sadly causing the camera to be powered on what looks to be most devices.
  # For some reason, this completely nullifies the soc power management on modern laptops and can result in increases from 3W to 8W at idle!
  config = mkIf cfg.enable {
    # WirePlumber looks in ~/.config/wireplumber/wireplumber.conf.d/
    xdg.configFile."wireplumber/wireplumber.conf.d/10-disable-camera.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink cfg.sourcePath;
    };
  };
}
