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

  forAllSystems = lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
in {
  inherit
    isDirectory
    isNixFile
    mkRelativeToRoot
    getEntries
    ifFileExists
    forAllSystems
    ;
}
