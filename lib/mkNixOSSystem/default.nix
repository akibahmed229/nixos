/*
* My lib helper functions
* which will import ../hosts dir and create a list of nixos systems to be build
*/
{
  lib ? throw "lib is not defined",
  pkgs ? throw "pkgs is not defined",
  system ? throw "system is required",
  home-manager ? throw "home-manager is required",
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
          // lib.mapAttrs' (n: v: lib.nameValuePair n v) specialArgs;
        modules =
          # configuration of nixos
          [
            (import /${path}/configuration.nix)
            (import /${path}/${name})
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = lib.mkDefault true;
                useUserPackages = lib.mkDefault true;
                extraSpecialArgs = lib.mapAttrs' (n: v: lib.nameValuePair n v) specialArgs;
              };
            }
          ];
      };
    }
    else {
      inherit name value;
    };

  # Map and filter out non-directories from the list of files
  processed = lib.mapAttrs' processDir getinfo;
  validAttrs = lib.filterAttrs (_: v: v != "regular" && v != "symlink" && v != "unknown") processed;

  # Convert to list of attribute sets for listToAttrs (haha I'm so funny)
  validList = map (name: {
    inherit name;
    value = validAttrs.${name};
  }) (lib.attrNames validAttrs);
in
  builtins.listToAttrs validList
