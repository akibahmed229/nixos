{
  pkgs,
  self,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
  HomeModuleFolder =
    mkRelativeToRoot
    "modules/predefiend/home-manager/kitty/kitty.conf";
in {
  home.packages = with pkgs; [
    kitty # GPU-based terminal emulator.
  ];

  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    shellIntegration.enableBashIntegration = true;
    shellIntegration.enableZshIntegration = true;
    extraConfig = builtins.readFile HomeModuleFolder;
  };
}
