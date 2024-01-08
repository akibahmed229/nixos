pkgs: {
  nvchad = pkgs.callPackage ./nvchad/default.nix {};
  custom_sddm = pkgs.callPackage ./sddm/sddm.nix {};

}
