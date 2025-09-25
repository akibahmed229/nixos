/*
* This function is used to import all the Nix modules from a given directory path.
* The function reads the directory contents and imports the modules from the directory.
* The function ignores the default.nix file and non-regular files.
* The function returns a set of imported modules.
* The directory structure should be as follows:
* - main directory (e.g., "nixos-modules")
                          - module1
                          - default.nix
                          - module2 (can contain nested modules)
                          - option1/default.nix
                          - option2/default.nix
*/
{lib}: path: let
  inherit
    (lib)
    attrsets
    mapAttrs'
    removeSuffix
    isDirectory
    isNixFile
    getEntries
    mkRecursiveScanPaths
    ;

  # Function to import modules from valid directories or files
  processModule = name: attr: let
    fullpath = path + "/${name}";
  in
    if isDirectory attr
    then {
      # For directories, create a module that recursively imports all .nix files inside it.
      # This correctly handles nested structures like `somenew`.
      inherit name;
      value = {imports = mkRecursiveScanPaths fullpath;};
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
  # - `self.nixosModules.<foldername>`
  # - `self.homeManagerModules.<foldername>`

  # Ex:-  modules/custom
            ├── home-manager
            │   ├── look
            │   │   └── theme
            │   │       └── default.nix
            │   │       icon
            │   │       └── default.nix
            │   └── monitor
            │       └── default.nix
            └── nixos

  # - `self.homeManagerModules.look` # will include all module recursively under that directory
  # - `self.homeManagerModules.monitor`

  */
  (attrsets.filterAttrs (_: m: m != null) processedModules)
  // {
    /*
    # Default module imports all the available modules in the parent directory
    # available through the
    # - `self.nixosModules.default`
    # - `self.homeModules.default`
    */
    default.imports = mkRecursiveScanPaths "${path}/.";
  }
