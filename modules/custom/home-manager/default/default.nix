{self, ...}: let
  inherit (self.lib) mkScanPath;

  module = mkScanPath ../.;
in {
  imports = module;
}
