# NixOS configuration with home-manager as a module in flakes

{ lib
, inputs
, unstable
, nixos
, system
, theme
, state-version
, nix-index-database
, home-manager
, hyprland
, plasma-manager
, user
, ...
}:

{
  # Host desktop configuration ( main system)
  desktop = lib.nixosSystem {
    inherit system;

    specialArgs = { inherit user inputs unstable state-version; };
    modules = [
      # "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" # uncomment to  have  live cd, which can be used to configure the current system  into bootable iso
      # configuration of nixos 
      ./configuration.nix
      ./desktop
      nix-index-database.nixosModules.nix-index
      # optional to also wrap and install comma
      { programs.nix-index-database.comma.enable = true; }
      inputs.impermanence.nixosModules.impermanence
      inputs.disko.nixosModules.default

      # Home manager configuration as a module
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = false;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit user inputs unstable theme state-version; }; # pass inputs && variables to home-manager
        home-manager.users.${user} = {
          imports = [
            nix-index-database.hmModules.nix-index
            # optional to also wrap and install comma
            { programs.nix-index-database.comma.enable = true; }
          ] ++
          [
            # inputs.plasma-manager.homeManagerModules.plasma-manager  # uncommnet to use KDE Plasma 
            hyprland.homeManagerModules.default # uncommnet to use hyprland
            { wayland.windowManager.hyprland.systemd.enable = true; }
          ] ++
          [
            # config of home-manager 
            ../home-manager/home.nix
          ] ++
          [
            #../home-manager/gnome/home.nix # uncommnet to use gnome
            ../home-manager/hyprland/home.nix
          ];
        };
      }
    ];
  };

  # Host virt-managet configuration ( virtualization system)
  virt = lib.nixosSystem {
    inherit system;

    specialArgs = { inherit user inputs unstable state-version; };
    modules = [
      # "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" # uncomment to  have  live cd, which can be used to configure the current system  into bootable iso
      inputs.disko.nixosModules.default
      ./configuration.nix
      ./virt
      nix-index-database.nixosModules.nix-index
      inputs.impermanence.nixosModules.impermanence

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit user inputs theme hyprland state-version; };
        home-manager.users.${user} = {
          imports = [ (import ../home-manager/home.nix) ] ++
            [ (import ../modules/predefiend/home-manager/impermanence/impermanence.nix) ] ++
            [ nix-index-database.hmModules.nix-index ];
        };
      }
    ];
  };
}

