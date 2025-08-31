/*
Usage:
  recursiveImport {inherit self lib pkgs;} ./modules
  or
  recursiveImport ./modules

Example file tree:
  ./modules/
    foo.nix       → { lib, ... }: { services.foo.enable = true; }
    bar.nix       → { services.bar.enable = true; }

Output (list of attrsets):
  [
    { services.foo.enable = true; }
    { services.bar.enable = true; }
  ]
*/
{lib}: {...} @ args
: let
  # Recursively scan a directory for all `.nix` files (excluding default.nix)
  recursiveScanPaths = path:
    lib.flatten (
      builtins.attrValues (
        builtins.mapAttrs (
          name: _type:
            if (_type == "directory")
            then recursiveScanPaths (path + "/${name}") # go deeper
            else if (name != "default.nix") && (lib.strings.hasSuffix ".nix" name)
            then path + "/${name}" # collect nix file
            else []
        ) (builtins.readDir path)
      )
    );

  # Import all `.nix` files found by recursiveScanPaths
  recursiveImport = path:
    builtins.map
    (
      path: let
        imported = import path;
      in
        # Normalize both module styles:
        # - foo.nix as `{ lib, ... }: { ... }`
        # - bar.nix as `{ ... }`
        if builtins.isFunction imported
        then imported args
        else imported
    )
    (recursiveScanPaths path);
in
  recursiveImport
