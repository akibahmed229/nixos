{self, ...}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  home.file = {
    ".ssh/config" = {
      source =
        mkRelativeToRoot
        "modules/predefiend/home-manager/ssh/config";
      recursive = true;
    };
  };
}
