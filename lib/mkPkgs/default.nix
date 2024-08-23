{
  system ? "x86_64-linux",
  nixpkgs ? {},
  ...
}: path: let
  inherit (nixpkgs) lib;
  inherit (builtins) readDir;
  inherit (lib) mapAttrs' pathExists filterAttrs attrNames lists;
  pkgs = import nixpkgs {inherit system;};

  # Read directory contents from the provided path
  getinfo = readDir path;

  # Function to check if a file exists and import it
  ifFileExists = _path:
    if pathExists _path
    then _path
    else throw "File not found: ${_path}";

  # Function to process directories for pkgs
  processDirPkgs = name: value:
    if value == "directory" && name != "shellscript" && name != "nixvim"
    then {
      inherit name;
      value = pkgs.callPackage (ifFileExists "${path}/${name}/default.nix") {};
    }
    else {
      inherit name value;
    };

  # Process directory contents for the main directories
  processe1 = mapAttrs' processDirPkgs getinfo;

  # Handle shellscript directory separately
  processShellScripts = name: value:
    if value == "directory" && name == "shellscript"
    then {
      name = mapAttrs' (n: v: n) (readDir "${path}/${name}");
      value = mapAttrs' (
        n: v:
          if (lib.hasSuffix ".nix" n)
          then import (ifFileExists "${path}/${name}/${n}") {inherit pkgs;}
          else throw "Unexpected file type in shellscript: ${n}"
      ) (readDir "${path}/${name}");
    }
    else {
      name = mapAttrs' (n: v: n) (readDir "${path}/${name}");
      inherit value;
    };

  processe2 = mapAttrs' processShellScripts (readDir "${path}/shellscript");

  # Merge processed attributes
  processed = lib.recursiveUpdate processe1 processe2;

  # Filter out non-directory entries from the processed list
  validAttrs = filterAttrs (_: v: v != "regular" && v != "symlink" && v != "unknown") processed;
in
  validAttrs
