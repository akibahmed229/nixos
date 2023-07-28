{ lib, inputs, unstable, system, home-manager, hyprland, user, ... }:

{
  desktop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit user inputs unstable; };
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

