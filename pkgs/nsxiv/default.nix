{
  lib,
  stdenv,
  fetchFromGitea,
  giflib,
  imlib2,
  libXft,
  libexif,
  libwebp,
  libinotify-kqueue,
}: let
  custom = builtins.path {
    path = ./custom;
    name = "custom";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "nsxiv";
    version = "32";

    src = fetchFromGitea {
      domain = "codeberg.org";
      owner = "nsxiv";
      repo = "nsxiv";
      rev = "v${finalAttrs.version}";
      hash = "sha256-UWaet7hVtgfuWTiNY4VcsMWTfS6L9r5w1fb/0dWz8SI=";
    };

    outputs = ["out" "man" "doc"];

    buildInputs =
      [
        giflib
        imlib2
        libXft
        libexif
        libwebp
      ]
      ++ lib.optional stdenv.isDarwin libinotify-kqueue;

    postPatch = ''
      cp ${custom}/config.h config.h
    '';

    env.NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-linotify";

    makeFlags = ["CC:=$(CC)"];

    installFlags = ["PREFIX=$(out)"];

    installTargets = ["install-all"];

    meta = {
      homepage = "https://nsxiv.codeberg.page/";
      description = "New Suckless X Image Viewer";
      mainProgram = "nsxiv";
      license = lib.licenses.gpl2Plus;
      maintainers = with lib.maintainers; [akibahmed229];
      platforms = lib.platforms.unix;
    };
  })
