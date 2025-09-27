/*
 Aggregates all custom helper functions for easier access.

    - Core (system-level): mkSystem, mkFlake, mkDerivation, mkOverlay, mkModule
    - Helpers (user-level): mkImport, mkImportModulesFrom, mkScanPath, mkRecursiveScanPaths, etc.

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
{lib}: let
  myUtils =
    (import ./mkUtils {inherit lib;})
    // (import ./mkImport {inherit lib;})
    // (import ./mkScan {inherit lib;});
in {
  # Core functions (system level)
  /*
  # NOTE:

  # mkSystem function is created before other custom helper functions (getEntries, isDirectory, etc.)
  # are defined in my library. Therefore, mkSystem has no knowledge of them.
  # So if i want to use my custom helper function inside my mkSystem then i have to explecitely import (eg {inherit myUtils;})

  # The reason it (lib) works for (mkImport, mkModule and all other helper function excluding mkSystem)  is likely because
  # i passed the fully assembled library to it somewhere else, whereas mkSystem is being constructed with only the initial, basic lib.
  */
  mkFlake = import ./mkFlake {inherit lib;};
  mkSystem = import ./mkSystem {inherit myUtils;};
  mkModule = import ./mkModule {inherit lib;};
  mkOverlay = import ./mkOverlays {inherit lib;};
  mkDerivation = import ./mkDerivation {inherit lib;};

  # Helper functions (user level)
  inherit
    # Expose all utilities at the top level.
    (myUtils)
    isDirectory
    isNixFile
    mkRelativeToRoot
    getEntries
    ifFileExists
    ifPathExistsFn
    ifPathExistsSet
    forAllSystems
    mkImport
    mkImportModulesFrom
    mkScanPath # scan dir for nix files → [paths]
    mkRecursiveScanPaths # recursive scan dir → [paths]
    mkScanImportPath # scan + import dir → [modules]
    mkRecursiveScanImportPaths # recursive scan + import dir → [modules]
    ;
}
