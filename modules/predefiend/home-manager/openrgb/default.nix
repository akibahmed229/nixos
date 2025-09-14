{self, ...}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  home.file = {
    ".config/OpenRGB" = {
      source =
        mkRelativeToRoot
        "modules/predefiend/home-manager/openrgb/config";
      recursive = true;
    };
  };
}
