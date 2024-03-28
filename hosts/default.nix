# NixOS configuration with home-manager as a module in flakes

{ self
, lib
, inputs
, unstable
, system
, theme
, state-version
, nix-index-database
, home-manager
, hyprland
, plasma-manager
, user
, hostname
, devicename
, ...
}:

{
  # Host desktop configuration ( main system)
  desktop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs self user hostname devicename unstable state-version; };
    modules =
      # configuration of nixos 
      [ (import ./configuration.nix) ] ++
      [ (import ./desktop) ] ++
      [ self.nixosModules.default ] ++ # Custom nixos modules
      [ nix-index-database.nixosModules.nix-index { programs.nix-index-database.comma.enable = true; } ] ++ # optional to also wrap and install comma
      [ inputs.impermanence.nixosModules.impermanence ] ++
      [ inputs.disko.nixosModules.default ] ++
      [
        # Home manager configuration as a module
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs self user unstable theme state-version; }; # pass inputs && variables to home-manager
            users.${user} = {
              imports =
                [ nix-index-database.hmModules.nix-index { programs.nix-index-database.comma.enable = true; } ] ++ # optional to also wrap and install comma
                [ hyprland.homeManagerModules.default { wayland.windowManager.hyprland.systemd.enable = true; } ] ++
                [ self.homeManagerModules.default ] ++ # Custom home-manager modules
                # [ inputs.plasma-manager.homeManagerModules.plasma-manager ] ++ # uncommnet to use KDE Plasma 
                [ (import ../home-manager/home.nix) ] ++ # config of home-manager 
                [ (import ../home-manager/hyprland/home.nix) ];
              # [ (import  ../home-manager/gnome/home.nix ) ; ## uncommnet to use gnome
            };
          };
        }
      ];
  };

  # Host virt-managet configuration ( virtualization system)
  virt = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs user hostname devicename unstable state-version; };
    modules =
      # [ "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ] ++ # uncomment to  have  live cd, which can be used to configure the current system  into bootable iso
      [ (import ./configuration.nix) ] ++
      [ (import ./virt) ] ++
      [ self.nixosModules.default ] ++ # Custom nixos modules
      [ nix-index-database.nixosModules.nix-index ] ++
      [ inputs.impermanence.nixosModules.impermanence ] ++
      [ inputs.disko.nixosModules.default ] ++
      [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs user hostname devicename theme hyprland state-version; };
            users.${user} = {
              imports =
                [ self.homeManagerModules.default ] ++ # Custom home-manager modules
                [ (import ../home-manager/home.nix) ] ++
                # [ (import ../modules/predefiend/home-manager/impermanence/impermanence.nix) ] ++
                [ nix-index-database.hmModules.nix-index ];
            };
          };
        }
      ];
  };

  # Host virt-managet configuration ( virtualization system)
  # Can Access through  "nix build .#nixosConfigurations.currentSystemISO.config.system.build.isoImage"
  currentSystemISO = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs self user hostname devicename unstable state-version; };
    modules =
      [ "${inputs.nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ] ++ # uncomment to  have  live cd, which can be used to configure the current system  into bootable iso
      [
        (import ./configuration.nix)
        {
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          grub.enable = lib.mkForce false;
          networking.networkmanager.enable = lib.mkForce false;
        }
      ] ++
      [ (import ../home-manager/hyprland/default.nix) ] ++
      [ (import ../modules/predefiend/nixos/sops ) ] ++
      [ self.nixosModules.default ] ++ # Custom nixos modules
      [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs self user unstable hostname theme hyprland state-version; };
            users.${user} = {
              imports =
                [ self.homeManagerModules.default ] ++ # Custom home-manager modules
                [ (import ../home-manager/home.nix) ] ++
                [ (import ../home-manager/hyprland/home.nix) ];
            };
          };
        }
      ];
  };
}
