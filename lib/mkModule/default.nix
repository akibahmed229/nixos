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
{lib}: path: let
  inherit (builtins) readDir;
  inherit (lib) strings attrsets mapAttrs' removeSuffix;

  # Utility to check if a given path points to a directory
  isDirectory = attr: attr == "directory";

  # Utility to check if a given path is a Nix file
  isNixFile = name: strings.hasSuffix ".nix" name;

  # Reads the directory contents from the provided path and filters out unwanted entries
  getModules = path: let
    contents = readDir path;
  in
    # Keep only directories with a default.nix file and nix files themselves
    attrsets.filterAttrs (
      name: attr:
        isDirectory attr || (isNixFile name && name != "default.nix")
    )
    contents;

  # Function to import modules from valid directories or files
  processModule = name: attr:
    if isDirectory attr
    then {
      # Import the default.nix from directories
      inherit name;
      value = import (path + "/${name}");
    }
    else if isNixFile name
    then {
      # Import standalone .nix files
      name = removeSuffix ".nix" name; # Remove the ".nix" suffix from the file name
      value = import (path + "/${name}");
    }
    else
      # Return null for unsupported file types (acts as a no-op)
      null;

  # Apply the processing function to each valid module
  processedModules = mapAttrs' processModule (getModules path);
in
  # Filter out null values from the resulting attribute set (i.e., unsupported files)
  attrsets.filterAttrs (_: m: m != null) processedModules
