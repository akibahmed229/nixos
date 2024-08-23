{
  system ? "x86_64-linux",
  nixpkgs ? {},
  path ? throw "path required",
  ...
}: let
  inherit (nixpkgs) lib;
  inherit (builtins) readDir;
  inherit (lib) mapAttrs' pathExists filterAttrs recursiveUpdate removeSuffix;
  pkgs = import nixpkgs {inherit system;};

  # Read directory contents from the provided path
  getinfo = readDir path;

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
      value = pkgs.callPackage (ifFileExists "${path}/${name}/default.nix") {};
    }
    else {
      inherit name value;
    };

  # Process the "shellscript" directory and import regular files as Nix packages
  processShellScript = name: value:
    if value == "regular" # Only process regular files
    then {
      name = removeSuffix ".nix" name; # Remove the ".nix" suffix from the file name
      value = import "${path}/shellscript/${name}" {inherit pkgs;};
    }
    else {
      inherit name value;
    };

  # Process the main directory contents and filter out unwanted entries
  processedPkgs =
    filterAttrs (n: v: v != "regular" && v != "symlink" && v != "unknown" && n != "shellscript" && n != "nixvim")
    (mapAttrs' processDirPkgs getinfo);

  # Process the shellscript directory separately and filter out unwanted entries
  processedShellScript =
    filterAttrs (_: v: v != "directory" && v != "symlink" && v != "unknown")
    (mapAttrs' processShellScript (readDir "${path}/shellscript"));
in
  recursiveUpdate processedPkgs processedShellScript
