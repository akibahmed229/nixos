/*
* My lib helper functions
* which will import ../hosts dir and create a list of nixos systems to be build
*/
{
  lib ? throw "lib is not defined",
  pkgs ? import <nixpkgs> {},
  system ? "x86_64-linux",
  homeConf ? false,
  droidConf ? false,
  template ? false,
  nixpkgs ? {},
  specialArgs ? {},
  home-manager ? import <home-manager> {},
  nix-on-droid ? import <nix-on-droid> {},
  ...
}: path: let
  inherit (lib) nixosSystem mapAttrs' nameValuePair mkDefault filterAttrs attrNames lists;
  inherit (home-manager.lib) homeManagerConfiguration;
  inherit (nix-on-droid.lib) nixOnDroidConfiguration;

  getinfo = builtins.readDir path;

  # NixOS system
  processDirNixOS = name: value:
    if value == "directory"
    then {
      inherit name;
      value = nixosSystem {
        inherit system;
        specialArgs =
          {inherit system;}
          // mapAttrs' (n: v: nameValuePair n v) specialArgs;
        modules =
          # configuration of nixos
          [
            (import /${path}/configuration.nix)
            (import /${path}/${name})
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = mkDefault true;
                useUserPackages = mkDefault true;
                extraSpecialArgs = mapAttrs' (n: v: nameValuePair n v) specialArgs;
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
      value = homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = mapAttrs' (n: v: nameValuePair n v) specialArgs;
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

  # Nix On Droid system
  processDirNixOnDroid = name: value:
    if value == "directory"
    then {
      inherit name;
      value = nixOnDroidConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          overlays = [
            nix-on-droid.overlays.default
            # add other overlays
          ];
        };
        extraSpecialArgs = mapAttrs' (n: v: nameValuePair n v) specialArgs;
        modules =
          # configuration of nix-on-droid
          [
            (import /${path}/configuration.nix)
            (import /${path}/${name})
            {
              home-manager = {
                backupFileExtension = "hm-bak";
                useGlobalPkgs = true;
                extraSpecialArgs = mapAttrs' (n: v: nameValuePair n v) specialArgs;
              };
            }
          ];
        # set path to home-manager flake
        home-manager-path = home-manager.outPath;
      };
    }
    else {
      inherit name value;
    };

  processDirTemplate = name: value:
    if value == "directory"
    then {
      inherit name;
      value = {
        description = "Template for ${name} system";
        path = /${path}/${name};
      };
    }
    else {
      inherit name value;
    };

  # Map and filter out non-directories from the list of files
  processed =
    mapAttrs' (
      # Check if we are processing home-manager or nixos
      if homeConf
      then processDirHome # homeConf is true
      else if droidConf
      then processDirNixOnDroid # droidConf is true
      else if template
      then processDirTemplate # template is true
      else processDirNixOS
    )
    getinfo;
  validAttrs = filterAttrs (_: v: v != "regular" && v != "symlink" && v != "unknown") processed;

  # Convert to list of attribute sets for listToAttrs (haha I'm so funny)
  validList = map (name: {
    inherit name;
    value = validAttrs.${name};
  }) (attrNames validAttrs);

  # check if directly is empty
  isEmpty = _:
    if lists.length validList == 0
    then throw "No systems found in ${path}"
    else _;
in
  isEmpty builtins.listToAttrs validList
