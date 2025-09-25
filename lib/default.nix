/*
 Aggregates all custom helper functions for easier access.

    - Core (system-level): mkSystem, mkFlake, mkDerivation, mkOverlay, mkModule
    - Helpers (user-level): mkImport, mkImportPath, mkScanPath, mkRecursiveScanPaths, etc.

 This acts as a single entrypoint so other parts of your flake can just do:

    let
      myLib = import ./lib { inherit lib; };
    in
      {
        systems.desktop = myLib.mkSystem { ... };
        overlays.default = myLib.mkOverlay (final: prev: { ... });
        modules = myLib.mkRecursiveScanImportPaths ./modules;
      }

Instead of importing each helper manually.
*/
{lib}: rec {
  # Core functions (system level)
  mkFlake = import ./mkFlake;
  mkSystem = import ./mkSystem {
    myLib = {
      inherit
        isDirectory
        isNixFile
        getEntries
        ifFileExists
        ;
    };
  };
  mkModule = import ./mkModule {inherit lib;};
  mkOverlay = import ./mkOverlays {inherit lib;};
  mkDerivation = import ./mkDerivation {inherit lib;};

  # Helper functions (user level)
  mkImport = import ./mkImport {inherit lib;};
  mkRelativeToRoot = lib.path.append ../.; # relative path resolver from repo root

  inherit
    (import ./mkUtils {inherit lib;})
    isDirectory
    isNixFile
    getEntries
    ifFileExists
    ;

  inherit
    (import ./mkImportPath {inherit lib;})
    mkImportPath
    ;

  inherit
    (import ./mkScan {inherit lib;})
    mkScanPath # scan dir for nix files → [paths]
    mkRecursiveScanPaths # recursive scan dir → [paths]
    mkScanImportPath # scan + import dir → [modules]
    mkRecursiveScanImportPaths # recursive scan + import dir → [modules]
    ;
}
