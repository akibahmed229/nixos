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
  inherit (lib) attrsets mapAttrs' removeSuffix mkScanPath isDirectory isNixFile getEntries;

  # Function to import modules from valid directories or files
  processModule = name: attr: let
    fullpath = path + "/${name}";
  in
    if isDirectory attr
    then {
      # Import the default.nix from directories
      inherit name;
      value = import fullpath;
    }
    else if isNixFile name
    then {
      # Import standalone .nix files
      name = removeSuffix ".nix" name; # Remove the ".nix" suffix from the file name
      value = import fullpath;
    }
    else
      # Return null for unsupported file types (acts as a no-op)
      null;

  # Apply the processing function to each valid module
  processedModules = mapAttrs' processModule (getEntries path);
in
  /*
  # Filter out null values from the resulting attribute set (i.e., unsupported files)

  # available through the
      - `self.nixosModules.<foldername>.<your define option>`
      - `self.homeManagerModules.<foldername>.<your define option>`
  */
  (attrsets.filterAttrs (_: m: m != null) processedModules)
  // {
    /*
    # Default module imports all the available modules in the parent directory

    # available through the
         - `self.nixosModules.default`
         - `self.homeModules.default`
    */
    default.imports = mkScanPath "${path}/.";
  }
