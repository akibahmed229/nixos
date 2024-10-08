/*
* This is a Nix expression that dynamically import overlays from a directory. It is useful for managing multiple overlays in a single repository.

* The function takes the following arguments:
* - inputs: A set of Nix packages to be passed to the imported packages.
* - path: The path to the directory containing the Nix packages.

* The directory structure should be as follows:
* - main directory (e.g., "my-overlays")
*   - overlay1
*     - default.nix
*   - overlay2
*     - default.nix

  # This one brings our custom packages from the 'pkgs' directory
  # additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  # modifications = final: prev: {
  #   example =
  #     prev.example.overrideAttrs (oldAttrs: rec {
  #     ...
  #     });
  # };
*/
{lib}: {
  inputs ? {},
  path ? throw "path required",
  ...
}: let
  # Importing necessary functions and utilities from the provided imports
  inherit (builtins) readDir;
  inherit (lib) mapAttrs' attrsets strings removeSuffix;

  # Utility to check if a given path points to a directory
  isDirectory = attr: attr == "directory";

  # Utility to check if a given path is a Nix file
  isNixFile = name: strings.hasSuffix ".nix" name;

  # Reads the directory contents from the provided path and filters out unwanted entries
  getOverlays = path: let
    contents = readDir path;
  in
    # Keep only directories with a default.nix file and nix files themselves
    attrsets.filterAttrs (
      name: attr:
        isDirectory attr || (isNixFile name && name != "default.nix")
    )
    contents;

  # Process the overlays by importing them with the provided inputs and path
  processOverlays = name: value: let
    fullpath = path + "/${name}";
  in
    if isDirectory value
    then {
      # Import the default.nix from directories
      inherit name;
      value = import fullpath {inherit inputs;};
    }
    else if isNixFile name
    then {
      # Import standalone .nix files
      name = removeSuffix ".nix" name; # Remove the ".nix" suffix from the file name
      value = import fullpath {inherit inputs;};
    }
    else null;

  # Apply the processing function to each valid module
  processed =
    mapAttrs' processOverlays
    (getOverlays path);
in
  # Filter out null values from the resulting attribute set (i.e., unsupported files)
  attrsets.filterAttrs (_: m: m != null) processed
