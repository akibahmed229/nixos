{lib}: let
  # Utility to check if a given path points to a directory
  isDirectory = attr: attr == "directory";
  # Utility to check if a given path is a Nix file
  isNixFile = name: lib.strings.hasSuffix ".nix" name;

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
in {
  inherit isDirectory isNixFile getEntries ifFileExists;
}
