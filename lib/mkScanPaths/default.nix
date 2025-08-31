/*
* This function scans a directory for .nix files and directories, excluding the "default" directory and default.nix files.
* It returns a list of paths to the .nix files and directories.
*/
{lib}: let
  mkScanPaths = path:
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

  mkScanImportPaths = args: path:
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
    (mkScanPaths path);
in {
  inherit mkScanPaths mkScanImportPaths;
}
