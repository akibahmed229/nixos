/*
Imports all `.nix` files from a path (using mkScan/mkRecursiveScanPaths).

Handles both styles:
  - foo.nix: { lib, ... }: { ... }
  - bar.nix: { ... }
Example:
  mkImportPath { lib = pkgs.lib; } ./modules mkRecursiveScanPaths
*/
{lib}: let
  # Collects & normalizes modules into a list for imports in flake.nix.
  mkImportPath = {...} @ args: path: mkScan:
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
  inherit mkImportPath;
}
