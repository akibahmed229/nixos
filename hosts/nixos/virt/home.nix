# virt home-manager configuration
{
  self,
  lib,
  user,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms =
      [
        "firefox"
        "zsh"
        "tmux"
        "lf"
        "atuin"
        "nixvim"
        "stylix"
      ]
      ++ lib.optionals (user == "akib") [
        "git"
        "sops"
      ];
  };
}
