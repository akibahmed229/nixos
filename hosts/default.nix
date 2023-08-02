{ lib, inputs, unstable, system, home-manager, hyprland, plasma-manager, user, ... }:

{
  desktop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit user inputs self unstable; };
    modules = [
      ./configuration.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit user; };
          home-manager.users.${user} = {
            imports = [
              # inputs.plasma-manager.homeManagerModules.plasma-manager  # uncommnet to use KDE Plasma 
              ../home-manager/home.nix
            ];
          };
        }
    ];
  };
}

