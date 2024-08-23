{
  lib,
  pkgs ? import <nixpkgs> {},
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "obs-zoom-to-mouse";
  version = "v1.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "BlankSourceCode";
    repo = "obs-zoom-to-mouse";
    rev = version;
    sha256 = "sha256-CBuN2GrEqyEoH7kQ+kIFGW9H86zjUlZLhvrHSIh957M=";
  };

  # Fix output directory
  postInstall = ''
    mkdir -p $out/lib/obs-plugins
    mv obs-zoom-to-mouse.lua $out/lib/obs-plugins/
  '';

  meta = {
    description = "An OBS lua script to zoom a display-capture source to focus on the mouse";
    homepage = "https://github.com/BlankSourceCode/obs-zoom-to-mouse";
    maintainers = with lib.maintainers; [akibahmed229];
    platforms = lib.platforms.linux;
  };
}
