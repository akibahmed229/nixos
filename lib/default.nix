{lib, ...}: {
  # Core functions (system level)
  mkSystem = import ./mkSystem;
  mkDerivation = import ./mkDerivation;
  mkOverlay = import ./mkOverlays {inherit lib;};
  mkModule = import ./mkModule {inherit lib;};
  mkFlake = import ./mkFlake;

  # Helper functions (user level)
  mkImport = import ./mkImport {inherit lib;};
  mkRelativeToRoot = lib.path.append ../.; # appends a relative path from the current directory to the root directory
  mkScanPath = import ./mkScanPath {inherit lib;};
}
