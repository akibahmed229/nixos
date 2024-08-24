# patches takes a list of paths, not the string containing the contents of the patch
{inputs, ...}: (final: prev: {
  flatpak = prev.flatpak.overrideAttrs (o: {
    patches =
      (o.patches or [])
      ++ [
        (prev.fetchpatch {
          url = "https://raw.githubusercontent.com/NixOS/nixpkgs/b333f2676c963e7d17f948afd0caa9edae5bd0bd/pkgs/development/libraries/flatpak/fix-fonts-icons.patch";
          hash = "0kcah5vy46kfgfx2ynzrzddgvs8laqyhwici3b38257xl0ddx4gp";
        })
      ];
  });
})
