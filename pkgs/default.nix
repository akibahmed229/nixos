# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  nvchad = pkgs.callPackage ./nvchad { };

  obs-zoom-to-mouse = pkgs.callPackage ./obs-studio-plugins { };

  custom_sddm = pkgs.callPackage ./sddm/sddm.nix { };

  nix-update-input = import ./shellscript/nix-update-input.nix { inherit pkgs; };

  disko-formate = import ./shellscript/disko-formate.nix { inherit pkgs; };

  kernel-build-env = import ./shellscript/kernel-build-env.nix { inherit pkgs; };
}
