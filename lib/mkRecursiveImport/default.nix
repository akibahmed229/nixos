{lib}: let
  recursiveScanPaths = path:
    lib.flatten (
      builtins.attrValues (
        builtins.mapAttrs (
          name: _type:
            if (_type == "directory")
            then recursiveScanPaths (path + "/${name}")
            else if (name != "default.nix") && (lib.strings.hasSuffix ".nix" name)
            then path + "/${name}"
            else []
        ) (builtins.readDir path)
      )
    );

  recursiveImport = path:
    builtins.map (path: import path {})
    (recursiveScanPaths path);
in
  recursiveImport
