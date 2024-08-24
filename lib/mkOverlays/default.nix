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

  # Process the overlays by importing them with the provided inputs and path
  processOverlays = name: value: {
    inherit name;
    value = import /${path}/${name} {inherit inputs;};
  };

  # Process only the directories containing Nix files and ignore the default.nix file and non-regular files
  processed = attrsets.filterAttrs (_path: _type:
    (_type != "regular" && _type != "symlink" && _type != "unknown")
    || (_path != "default.nix") # ignore the default.nix file
    && (strings.hasSuffix ".nix" _path))
  (mapAttrs' processOverlays getinfo);
in
  processed
