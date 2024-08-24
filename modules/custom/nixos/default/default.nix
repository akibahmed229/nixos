# Default module imports all the available modules in the parent directory
{self, ...}: let
  inherit (self.lib) mkScanPath;

  # imports all the modules, one step backwards in the directory tree
  module = mkScanPath ../.;
in {
  imports = module; # available through the `self.nixosModules.default` import
}
