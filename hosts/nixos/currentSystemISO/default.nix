# `nix build .#nixosConfigurations.currentSystemISO.config.system.build.isoImage` - from nix-config directory to generate the iso manually
#
# Generated images will be output to the ~/nix-config/results directory unless drive is specified
{
  self,
  pkgs,
  user,
  lib,
  desktopEnvironment,
  state-version,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  imports = map mkRelativeToRoot [
    "home-manager/hyprland"
    "modules/predefiend/nixos/sops"
  ];

  # (Custom nixos modules)
  grub.enable = lib.mkForce false;
  networking = {
    hostName = lib.mkDefault "CurrentISO";
    wireless.enable = false;
  };

  nixpkgs.overlays = [
    self.overlays.nvim-overlay
  ];
  environment.systemPackages = with pkgs; [neovim cryptsetup spice-vdagent guestfs-tools];

  # Enables copy / paste when running in a KVM with spice.
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  # Use faster squashfs compression
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  home-manager = {
    useGlobalPkgs = false;
    users.${user} = {
      imports =
        map mkRelativeToRoot [
          "home-manager/home.nix"
          "home-manager/${desktopEnvironment}/home.nix"
        ]
        ++ [
          (import ./home.nix)
          {
            home = {
              stateVersion = state-version;
            };
          }
        ];
    };
  };
}
