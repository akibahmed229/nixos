{self, ...}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  home.file = {
    # libinput config that will disable mouse acceleration
    ".config/libinput/local-overrides.quirk" = {
      source =
        mkRelativeToRoot
        "modules/predefiend/home-manager/libinput/local-overrides.quirk";
      recursive = true;
    };
  };
}
