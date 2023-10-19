{ lib, inputs, unstable, system, theme, state-version, home-manager, hyprland, plasma-manager, user, ... }:

{
# Host desktop configuration
  desktop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit user inputs unstable state-version; };
    modules = [
      ./configuration.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit user inputs theme state-version; };
          home-manager.users.${user} = {
            imports = [
              # inputs.plasma-manager.homeManagerModules.plasma-manager  # uncommnet to use KDE Plasma 
              ../home-manager/home.nix
            ];
          };
        }
    ];
  };
  
# Host virt-managet configuration

  virt = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit user inputs unstable state-version; };
    modules = [
      ./configuration.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit user inputs theme state-version; };
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

