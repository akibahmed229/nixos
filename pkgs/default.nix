# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  nvchad = pkgs.callPackage ./nvchad { };
  obs-zoom-to-mouse = pkgs.callPackage ./obs-studio-plugins { };
  custom_sddm = pkgs.callPackage ./sddm/sddm.nix { };
  wallpaper = import ./shellscript/wallpaper.nix { inherit pkgs; };
  nix-update-input = import ./shellscript/nix-update-input.nix { inherit pkgs; };
  disko-formate = import ./shellscript/disko-formate.nix { inherit pkgs; };
  akibOS = import ./shellscript/akibOS.nix { inherit pkgs; };
  fileviewer = import ./shellscript/fileviewer.nix { inherit pkgs; };
}
