{ lib, inputs, system, home-manager, user, ... }:

{
  desktop = lib.nixosSystem {
    inherit system;
    modules = [
      ./configuration.nix

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit user; };
        home-manager.users.${user} = {
          imports = [
            ../home-manager/home.nix
          ];
        };
      }
    ];
  };
}

