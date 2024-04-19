{ lib, pkgs ? import <nixpkgs> { }, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "obs-zoom-to-mouse";
  version = "v1.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "BlankSourceCode";
    repo = "obs-zoom-to-mouse";
    rev = version;
    sha256 = "sha256-CBuN2GrEqyEoH7kQ+kIFGW9H86zjUlZLhvrHSIh957M=";
  };

  buildInputs = with pkgs; [ obs-studio ];

  installPhase = ''
    mkdir $out
    mkdir -p $out/share/obs/obs-plugins/frontend-tools/scripts
    cp -r obs-zoom-to-mouse.lua "$out/share/obs/obs-plugins/frontend-tools/scripts"
    # cp -r $out ${pkgs.obs-studio}/share/obs/obs-plugins/frontend-tools/scripts
  '';

  meta = {
    description = "An OBS lua script to zoom a display-capture source to focus on the mouse";
    homepage = "https://github.com/BlankSourceCode/obs-zoom-to-mouse";
    maintainers = with lib.maintainers; [ akibahmed229 ];
    platforms = lib.platforms.linux;
  };
}
