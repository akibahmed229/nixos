/*
* This function is used to import all the Nix modules from a given directory path.
* The function reads the directory contents and imports the modules from the directory.
* The function ignores the default.nix file and non-regular files.
* The function returns a set of imported modules.

* The directory structure should be as follows:
* - main directory (e.g., "nixos-modules")
*   - module1
*     - default.nix
*   - module2
*     - default.nix
*/
{lib, ...}: {
  inputs ? {},
  path ? throw "path required",
  ...
}: let
  # Importing necessary functions and utilities from the provided imports
  inherit (builtins) readDir;
  inherit (lib) mapAttrs' attrsets strings;

  # Read directory contents from the provided path
  getinfo = readDir path;

  # Process the module by importing them with the provided path
  processesModule = name: value: {
    inherit name;
    value = import /${path}/${name};
  };

  # Process only the directories containing Nix files and ignore the default.nix file and non-regular files
  processed = attrsets.filterAttrs (_path: _type:
    (_type != "regular" && _type != "symlink" && _type != "unknown")
    || (_path != "default.nix") # ignore the default.nix file
    && (strings.hasSuffix ".nix" _path))
  (mapAttrs' processesModule getinfo);
in
  processed
