/*
* This function scans a directory for .nix files and directories, excluding the "default" directory and default.nix files.
* It returns a list of paths to the .nix files and directories.
*/
{lib}: let
  inherit (lib) mkImportPath;

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
            else if (name != "default.nix") && (lib.strings.hasSuffix ".nix" name)
            then path + "/${name}" # collect nix file
            else []
        ) (builtins.readDir path)
      )
    );

  mkScanImportPath = args: path: mkImportPath args path mkScanPath;

  mkRecursiveImportPaths = args: path: mkImportPath args path mkRecursiveScanPaths;
in {
  inherit mkScanPath mkRecursiveScanPaths mkScanImportPath mkRecursiveImportPaths;
}
