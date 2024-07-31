# NixOS configuration with home-manager as a module in flakes
{
  self,
  lib,
  inputs,
  unstable,
  system,
  desktopEnvironment,
  theme,
  state-version,
  home-manager,
  user,
  hostname,
  devicename,
  ...
}: {
  # Host desktop configuration ( main system)
  desktop = lib.nixosSystem {
    inherit system;
    specialArgs = {inherit inputs self user hostname devicename desktopEnvironment unstable state-version;};
    modules =
      # configuration of nixos
      [
        (import ./configuration.nix)
        (import ./desktop)
        inputs.disko.nixosModules.default
      ]
      ++ [
        # Home manager configuration as a module
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            extraSpecialArgs = {inherit inputs self user unstable desktopEnvironment theme state-version;}; # pass inputs && variables to home-manager
            users.${user} = {
              imports = [
                (import ../home-manager/home.nix) # config of home-manager
                (import ../home-manager/${desktopEnvironment}/home.nix)
              ];
            };
          };
        }
      ];
  };

  # Host virt-managet configuration ( virtualization system)
  virt = lib.nixosSystem {
    inherit system;
    specialArgs = {inherit inputs self user hostname devicename unstable state-version;};
    modules =
      # [ "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ] ++ # uncomment to  have  live cd, which can be used to configure the current system  into bootable iso
      [
        (import ./configuration.nix)
        (import ./virt)
        inputs.disko.nixosModules.default
      ]
      ++ [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {inherit inputs self user hostname devicename theme unstable state-version;};
            users.${user} = {
              imports = [(import ../home-manager/home.nix)];
            };
          };
        }
      ];
  };

  # Host virt-managet configuration ( virtualization system)
  # Can Access through  "nix build .#nixosConfigurations.currentSystemISO.config.system.build.isoImage"
  currentSystemISO = lib.nixosSystem {
    inherit system;
    specialArgs = {inherit inputs self user hostname devicename unstable state-version;};
    modules =
      ["${inputs.nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"] # uncomment to  have  live cd, which can be used to configure the current system  into bootable iso
      ++ [
        (import ./configuration.nix)
        {
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          grub.enable = lib.mkForce false;
          networking.networkmanager.enable = lib.mkForce false;

          # Enables copy / paste when running in a KVM with spice.
          services.spice-vdagentd.enable = true;
          # Use faster squashfs compression
          isoImage.squashfsCompression = "gzip -Xcompression-level 1";
        }
      ]
      ++ [
        (import ../home-manager/hyprland/default.nix)
        (import ../modules/predefiend/nixos/sops)
      ]
      ++ [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            extraSpecialArgs = {inherit inputs self user unstable hostname theme state-version;};
            users.${user} = {
              imports = [
                (import ../home-manager/home.nix)
                (import ../home-manager/hyprland/home.nix)
              ];
            };
          };
        }
      ];
  };
}
