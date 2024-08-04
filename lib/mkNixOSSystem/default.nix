/*
* My lib helper functions
* which will import ../hosts dir and create a list of nixos systems to be build
*/
{
  lib,
  pkgs,
  system,
  home-manager,
  specialArgs ? {},
  ...
}: path: let
  getinfo = builtins.readDir path;

  processDir = name: value:
    if value == "directory"
    then {
      inherit name;
      value = lib.nixosSystem {
        inherit system;
        specialArgs =
          {inherit system;}
          // lib.mapAttrs' (name: value: {inherit name value;}) specialArgs;
        modules =
          # configuration of nixos
          [
            (import /${path}/configuration.nix)
            (import /${path}/${name})
            home-manager.nixosModules.home-manager
          ];
      };
    }
    else {
      inherit name value;
    };

  # Map and filter out non-directories from the list of files
  processed = lib.mapAttrs' processDir getinfo;
  validAttrs = lib.filterAttrs (_: value: value != "regular" && value != "symlink" && value != "unknown") processed;

  # Convert to list of attribute sets for listToAttrs (haha I'm so funny)
  validList = map (name: {
    inherit name;
    value = validAttrs.${name};
  }) (lib.attrNames validAttrs);
in
  builtins.listToAttrs validList
