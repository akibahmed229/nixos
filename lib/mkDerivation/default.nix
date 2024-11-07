/*
* This is a Nix expression that dynamically imports Nix packages from a directory and make derivation.
* It reads the contents of a directory and imports the Nix packages based on the directory structure.
* The directory structure should be as follows:
* - main directory (e.g., "my-packages")
*   - package1
*     - default.nix
*   - package2
*     - default.nix
*   - shellscript
*     - script1.nix
*     - script2.nix
*     - ...
* The main directory contains subdirectories for each package, and each package directory contains a default.nix file.
* The shellscript directory contains Nix scripts that are imported as packages. The script files should have a ".nix" extension.
*/
{
  system ? "x86_64-linux",
  nixpkgs ? {},
  path ? throw "path required",
  ...
}: let
  # Importing necessary functions and utilities from the provided imports
  inherit (nixpkgs) lib;
  inherit (builtins) readDir;
  inherit (lib) mapAttrs' pathExists filterAttrs mergeAttrs removeSuffix attrsets strings;

  # Import the Nix packages
  pkgs = import nixpkgs {inherit system;};
  # Function to check if a file exists and return the path or throw an error if not found
  ifFileExists = _path:
    if pathExists _path
    then _path
    else throw "File not found: ${_path}";

  # Function to process directories and load Nix packages
  processDirPkgs = name: value:
    if (value == "directory" && name != "nixvim") # Only process directories, skipping "nixvim"
    then {
      inherit name;
      value = pkgs.callPackage (ifFileExists (path + "/${name}")) {};
    }
    else {
      inherit name value;
    };

  # Process the "shellscript" directory and import regular files as Nix packages
  processDirShellScript = name: value:
    if value == "regular" # Only process regular files
    then {
      name = removeSuffix ".nix" name; # Remove the ".nix" suffix from the file name
      value = import (path + "/shellscript/${name}") {inherit pkgs;};
    }
    else {
      inherit name value;
    };

  # Process the main directory contents and filter out unwanted entries
  processedPkgs =
    filterAttrs (_path: _type: (_type
      == "directory"
      || (_path != "shellscript" && _path != "nixvim")))
    (mapAttrs' processDirPkgs
      (readDir path));

  # Process the shellscript directory separately and filter out unwanted entries
  processedShellScript =
    attrsets.filterAttrs (_path: _type:
      (_type != "directory" && _type != "symlink" && _type != "unknown")
      || (_path != "default.nix") # ignore the default.nix file
      && (strings.hasSuffix ".nix" _path))
    (mapAttrs' processDirShellScript
      (readDir "${path}/shellscript"));
in
  # Merge the processed packages and shell scripts
  mergeAttrs processedPkgs processedShellScript
