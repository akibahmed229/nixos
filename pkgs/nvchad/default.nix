{
  lib,
  pkgs ? import <nixpkgs> {},
  ...
}: let
  custom = builtins.path {
    path = ./custom;
    name = "custom";
  };
in
  pkgs.stdenv.mkDerivation {
    pname = "nvchad";
    version = "2.5";

    src = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "refs/heads/v2.5";
      sha256 = "sha256-u5zF9UuNt+ndeWMCpKbebYYW8TR+nLeBvcMy3blZiQw=";
    };

    dontFixup = true; # tell derivations to not fixup the output

    installPhase = ''
      mkdir $out
      cp -r * "$out/"
      mkdir -p "$out/lua/custom"
      cp -r ${custom}/* "$out/lua/custom/"
      touch "$out/lazy-lock.json"
      chmod -R 0777 "$out/lazy-lock.json"
    '';

    meta = with lib; {
      description = "NvChad";
      homepage = "https://github.com/NvChad/NvChad";
      platforms = platforms.all;
      maintainers = [maintainers.akibahmed229];
      license = licenses.gpl3;
    };
  }
