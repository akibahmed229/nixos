/*
* My lib helper functions
* which will import ../hosts dir and create a list of nixos systems to be build
*/
{
  lib ? throw "lib is not defined",
  pkgs ? import <nixpkgs> {},
  system ? "x86_64-linux",
  homeConf ? false,
  home-manager ? import <home-manager> {},
  specialArgs ? {},
  ...
}: path: let
  getinfo = builtins.readDir path;

  # NixOS system
  processDirNixOS = name: value:
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

  # Home manager system
  processDirHome = name: value:
    if value == "directory"
    then {
      inherit name;
      value = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = lib.mapAttrs' (n: v: lib.nameValuePair n v) specialArgs;
        modules = [
          # configuration of home-manager
          (import /${path}/home.nix)
          (import /${path}/${name})
        ];
      };
    }
    else {
      inherit name value;
    };

  # Map and filter out non-directories from the list of files
  processed =
    lib.mapAttrs' (
      # Check if we are processing home-manager or nixos
      if homeConf
      then processDirHome
      else processDirNixOS
    )
    getinfo;
  validAttrs = lib.filterAttrs (_: v: v != "regular" && v != "symlink" && v != "unknown") processed;

  # Convert to list of attribute sets for listToAttrs (haha I'm so funny)
  validList = map (name: {
    inherit name;
    value = validAttrs.${name};
  }) (lib.attrNames validAttrs);

  # check if directly is empty
  isEmpty = _:
    if lib.lists.length validList == 0
    then throw "No systems found in ${path}"
    else _;
in
  isEmpty builtins.listToAttrs validList
