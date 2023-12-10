# NixOS configuration with home-manager as a module in flakes

{ lib, inputs, unstable, system, theme, state-version, nix-index-database, home-manager, hyprland, plasma-manager, user, ... }:

{
# Host desktop configuration ( main system)
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
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit user inputs unstable theme state-version; };
          home-manager.users.${user} = {
            imports = [
              # inputs.plasma-manager.homeManagerModules.plasma-manager  # uncommnet to use KDE Plasma 
              ../home-manager/home.nix
              ../home-manager/gnome/home.nix
              nix-index-database.hmModules.nix-index
              # optional to also wrap and install comma
              # { programs.nix-index-database.comma.enable = true; }
              # hyprland.homeManagerModules.default # uncommnet to use hyprland
            ];
          };
        }
    ];
  };
  
# Host virt-managet configuration ( virtualization system)
  virt = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit user inputs unstable  state-version; };
    modules = [
      ./configuration.nix
      ./virt
       nix-index-database.nixosModules.nix-index

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit user inputs theme hyprland state-version; };
          home-manager.users.${user} = {
            imports = [
              # inputs.plasma-manager.homeManagerModules.plasma-manager  # uncommnet to use KDE Plasma 
              ../home-manager/home.nix
              nix-index-database.hmModules.nix-index
              #../home-manager/hyprland/home.nix
              #hyprland.homeManagerModules.default # uncommnet to use hyprland
            ];
          };
        }
    ];
  };
}

