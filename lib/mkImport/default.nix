/*
# 1. mkImport: Import a list of modules from a given base path.

# Usage:
  mkImport {
    lib = pkgs.lib;
    path = ./modules;
    ListOfPrograms = [ "programA" "programB" ];
  }

# Example:
  If `path = ./modules` and `ListOfPrograms = [ "foo" "bar" ]`,
  it will try to import:
    ./modules/foo/default.nix
    ./modules/bar/default.nix

# 2. mkImportModulesFrom: Imports all `.nix` files from a path (using mkScan/mkRecursiveScanPaths).

# Handles both styles:
  - foo.nix: { lib, ... }: { ... }
  - bar.nix: { ... }
# Example:
  mkImportPath { lib = pkgs.lib; } ./modules mkRecursiveScanPaths
*/
{lib}: let
  inherit
    (lib)
    lists
    concatStringsSep
    flatten
    ifFileExists
    ;
  inherit
    (builtins)
    trace
    ;

  mkImport = {
    path ? throw "path is required",
    ListOfPrograms ? [],
  }:
    trace "Importing modules: ${concatStringsSep ", " (flatten ListOfPrograms)}"
    (
      lists.map (name: ifFileExists (path + "/${name}"))
      (flatten ListOfPrograms)
    );

  # Collects & normalizes modules into a list for imports in flake.nix.
  mkImportModulesFrom = {...} @ args: path: mkScan:
    builtins.map
    (
      path: let
        imported = import path;
      in
        # Normalize both module styles:
        # - foo.nix as `{ lib, ... }: { ... }`
        # - bar.nix as `{ ... }`
        if builtins.isFunction imported
        then imported args
        else imported
    )
    (mkScan path);
in {
  inherit
    mkImport
    mkImportModulesFrom
    ;
}
