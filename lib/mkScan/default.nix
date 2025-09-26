/*
* mkScan utilities for discovering and importing `.nix` modules.
*
* Functions:
* - mkScanPath path
*     → Returns list of direct .nix files + subdirs in `path`
*       (ignores `default/` dirs and `default.nix`).
*     Example:
*       mkScanPath ./modules
*       # => [ ./modules/foo.nix ./modules/bar ./modules/baz.nix ]
*
* - mkRecursiveScanPaths path
*     → Recursively collects all .nix files under `path`
*       (excluding default.nix).
*     Example:
*       mkRecursiveScanPaths ./modules
*       # => [ ./modules/foo.nix ./modules/bar/baz.nix ./modules/bar/qux.nix ]
*
* - mkScanImportPath args path
*     → Like mkScanPath, but imports each .nix file/module with `args`.
*
* - mkRecursiveScanImportPaths args path
*     → Like mkRecursiveScanPaths, but recursively imports with `args`.
*
* Usage:
*   let
*     scan = import ./lib/mkScan { lib = nixpkgs.lib; };
*   in scan.mkRecursiveScanImportPaths { config = {}; pkgs = pkgs; } ./modules
*
*   # => [ { ...module1 config... } { ...module2 config... } ]
*/
{lib}: let
  inherit
    (lib)
    mkImportModulesFrom
    ;

  # Scans a directory for .nix files and subdirs (excludes default/ and default.nix)
  mkScanPath = path:
    builtins.map (f: "${path}/${f}") (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          name: _type:
            (_type == "directory" && name != "default") # include directories but exclude the "default" directory
            || (
              (name != "default.nix") # ignore default.nix
              && (lib.strings.hasSuffix ".nix" name) # include only .nix files
            )
        ) (builtins.readDir path)
      )
    );

  # Recursively scan a directory for all `.nix` files (excluding default.nix)
  mkRecursiveScanPaths = path:
    lib.flatten (
      builtins.attrValues (
        builtins.mapAttrs (
          name: _type:
            if (_type == "directory")
            then mkRecursiveScanPaths (path + "/${name}") # go deeper
            else if (lib.strings.hasSuffix ".nix" name)
            then path + "/${name}" # collect nix file
            else []
        ) (builtins.readDir path)
      )
    );

  # Like mkScanPath but imports each module with given args
  mkScanImportPath = args: path: mkImportModulesFrom args path mkScanPath;

  # Like mkRecursiveScanPaths but recursively imports each module with args
  mkRecursiveScanImportPaths = args: path: mkImportModulesFrom args path mkRecursiveScanPaths;
in {
  inherit
    mkScanPath
    mkRecursiveScanPaths
    mkScanImportPath
    mkRecursiveScanImportPaths
    ;
}
