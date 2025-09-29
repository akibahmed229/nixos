{lib}: let
  # Utility to check if a given path points to a directory
  isDirectory = attr: attr == "directory";
  # Utility to check if a given path is a Nix file
  isNixFile = name: lib.strings.hasSuffix ".nix" name;

  # relative path resolver from repo root
  mkRelativeToRoot = lib.path.append ../../.;

  # Read directory contents from the provided path
  getEntries = _path: let
    contents = builtins.readDir _path;
  in
    # Keep only directories with a default.nix file and nix files themselves
    lib.attrsets.filterAttrs (
      name: attr:
        isDirectory attr || (isNixFile name && name != "default.nix")
    )
    contents;

  # Function to check if a file exists at the specified path
  ifFileExists = _path:
    if builtins.pathExists _path
    then _path
    else throw "File not found: ${_path}";

  ifPathExistsFn = _path: mkFunc:
    if (lib.pathExists _path)
    then mkFunc _path
    else {};

  ifPathExistsSet = _path: mkSet:
    if (lib.pathExists _path)
    then mkSet
    else {};

  forAllSystems = perSystem: let
    # --- Customize your list of supported systems here ---
    supportedSystems = [
      "x86_64-linux" # For standard PCs and servers
      "i686-linux" # For 32-bit PCs and servers system
      "aarch64-linux" # For Raspberry Pi, some cloud servers, etc.
      "x86_64-darwin" # For Intel-based Macs
      "aarch64-darwin" # For Apple Silicon (M1/M2/M3) Macs
    ];
  in
    # This function takes the list of systems and your logic (`perSystem`)
    # and generates the final attribute set.
    lib.genAttrs supportedSystems perSystem;
in {
  inherit
    isDirectory
    isNixFile
    mkRelativeToRoot
    getEntries
    ifFileExists
    ifPathExistsFn
    ifPathExistsSet
    forAllSystems
    ;
}
