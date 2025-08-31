{lib}: let
  # Import all `.nix` files found by recursiveScanPaths
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
