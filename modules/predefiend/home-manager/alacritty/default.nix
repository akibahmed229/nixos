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
      alacritty # GPU-accelerated terminal emulator.
    ];
    file = {
      ".config/alacritty" = {
        source =
          mkRelativeToRoot
          "modules/predefiend/home-manager/alacritty/config";
        recursive = true;
      };
    };
  };
}
