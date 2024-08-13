# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  # additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  # modifications = final: prev: {
  #   example =
  #     prev.example.overrideAttrs (oldAttrs: rec {
  #     ...
  #     });
  # };

  discord-overlay = import ./discord {inherit inputs;};
  flatpak-overlay = import ./flatpak {inherit inputs;};
  chromium-overlay = import ./chromium {inherit inputs;};
  nvim-overlay = import ./nvim {inherit inputs;};
  unstable-packages = import ./unstable-packages {inherit inputs;};
  intel-latestKernel-overlay = import ./intel-kernel {inherit inputs;};
}
