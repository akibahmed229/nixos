# NixOS configuration with home-manager as a module in flakes

{ lib, inputs, unstable, system, theme, state-version, nix-index-database, home-manager, hyprland, plasma-manager, user, ... }:

{
# Host desktop configuration
  desktop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit user inputs unstable state-version; };
    modules = [
      ./configuration.nix
      ./desktop
       nix-index-database.nixosModules.nix-index
       # optional to also wrap and install comma
       # { programs.nix-index-database.comma.enable = true; }

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit user inputs theme state-version; };
          home-manager.users.${user} = {
            imports = [
              # inputs.plasma-manager.homeManagerModules.plasma-manager  # uncommnet to use KDE Plasma 
              ../home-manager/home.nix
              nix-index-database.hmModules.nix-index
              # optional to also wrap and install comma
              # { programs.nix-index-database.comma.enable = true; }
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
      ./virt

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

