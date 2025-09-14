{
  pkgs,
  self,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  home = {
    packages = with pkgs; [
      fastfetch
    ];
    file = {
      ".config/fastfetch" = {
        source =
          mkRelativeToRoot
          "modules/predefiend/home-manager/fastfetch/config";
        recursive = true;
      };
    };
  };
}
