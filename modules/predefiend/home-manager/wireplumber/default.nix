{self, ...}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  home.file = {
    # The camera's /dev/video file is kept open (without streaming), sadly causing the camera to be powered on what looks to be most devices.
    # For some reason, this completely nullifies the soc power management on modern laptops and can result in increases from 3W to 8W at idle!
    ".config/wireplumber/wireplumber.conf.d" = {
      source =
        mkRelativeToRoot
        "modules/predefiend/home-manager/wireplumber/wireplumber.conf.d"; # tells wireplumber to ignore cameras
      recursive = true;
    };
  };
}
