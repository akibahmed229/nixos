/*
* This is a Nix expression that dynamically imports Nix packages from a directory and make derivation.
*/
{lib}: {
  system ? "x86_64-linux",
  nixpkgs ? {},
  path ? throw "path required",
  ...
}: let
  ## --------------------------- SETUP & UTILITIES ---------------------------- ##
  inherit
    (lib)
    filterAttrs
    mapAttrs
    mapAttrs'
    removeSuffix
    hasSuffix
    pathExists
    ;

  pkgs = import nixpkgs {
    inherit system;
    config = {
      permittedInsecurePackages = ["qtwebengine-5.15.19"]; # FIXME
    };
  };

  # Read the top-level directory contents just once.
  topLevelEntries = builtins.readDir path;

  ## ---------------------- 1. PROCESS PACKAGE DIRECTORIES ---------------------- ##
  # First, find all subdirectories that are NOT named "shellscript".
  packageDirs =
    filterAttrs
    (name: type: type == "directory" && name != "shellscript")
    topLevelEntries;

  # Then, create a package from each of those directories.
  packages =
    mapAttrs
    (name: type: pkgs.callPackage (path + "/${name}") {})
    packageDirs;

  ## ------------------------ 2. PROCESS SHELL SCRIPTS ------------------------ ##
  # This whole block is conditional on the "shellscript" directory existing.
  shellScripts =
    if pathExists (path + "/shellscript")
    then let
      # Find all regular ".nix" files, excluding "default.nix".
      scriptFiles =
        filterAttrs
        (name: type:
          type == "regular" && hasSuffix ".nix" name && name != "default.nix")
        (builtins.readDir (path + "/shellscript"));

      # Import each script file.
      importedScripts =
        mapAttrs
        (name: type: import (path + "/shellscript/${name}") {inherit pkgs;})
        scriptFiles;
    in
      # Rename the attributes to remove the ".nix" suffix.
      mapAttrs' (name: value: {
        name = removeSuffix ".nix" name;
        inherit value;
      })
      importedScripts
    else {}; # If the directory doesn't exist, return an empty set.
in
  ## -------------------------- 3. COMBINE RESULTS -------------------------- ##
  # Use the `//` operator to merge the two attribute sets.
  packages // shellScripts
