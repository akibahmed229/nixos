{
  lib,
  stdenv,
  mdbook,
  ...
}: let
  custom = builtins.path {
    path = ./docs;
    name = "custom";
  };
in
  stdenv.mkDerivation {
    pname = "my-project-docs";
    version = "0.1.0";

    # Use the current directory as the source
    src = custom;

    # Add mdbook to the build environment
    nativeBuildInputs = [mdbook];

    # Commands to build the site
    buildPhase = ''
      runHook preBuild
      mdbook build
      runHook postBuild
    '';

    # Commands to install the site into the Nix store
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -R book/* $out/
      runHook postInstall
    '';

    meta = with lib; {
      description = "My Personal Docs";
      homepage = "https://github.com/akibahmed229/nixos";
      platforms = platforms.all;
      maintainers = [maintainers.akibahmed229];
      license = licenses.gpl3;
    };
  }
