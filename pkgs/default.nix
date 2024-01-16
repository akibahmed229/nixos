# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  nvchad = pkgs.callPackage ./nvchad/default.nix { };

  custom_sddm = pkgs.callPackage ./sddm/sddm.nix { };

  nix-update-input = pkgs.callPackage ./nix-update-input/updateInput.nix { };

}
