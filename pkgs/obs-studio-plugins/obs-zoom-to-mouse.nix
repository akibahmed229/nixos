{ lib, pkgs ? import <nixpkgs> { }, ... }:

stdenv.mkDerivation rec {
  pname = " obs-zoom-to-mouse";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "BlankSourceCode";
    repo = "obs-zoom-to-mouse";
    rev = version;
    hash = "sha256-rpZ/vR9QbWgr8n6LDv6iTRsKXSIDGy0IpPu1Uatb0zw=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    alsa-lib
    asio
    curl
    libremidi
    obs-studio
    opencv
    procps
    qtbase
    websocketpp
    xorg.libXScrnSaver
  ];

  dontWrapQtApps = true;

  postUnpack = ''
    cp -r ${libremidi.src}/* $sourceRoot/deps/libremidi
    chmod -R +w $sourceRoot/deps/libremidi
  '';

  postInstall = ''
    mkdir $out/lib $out/share
    mv $out/obs-plugins/64bit $out/lib/obs-plugins
    mv $out/data $out/share/obs
  '';

  meta = {
    description = "An OBS lua script to zoom a display-capture source to focus on the mouse";
    homepage = "https://github.com/BlankSourceCode/obs-zoom-to-mouse";
    maintainers = with lib.maintainers; [ BlankSourceCode ];
    platforms = lib.platforms.linux;
  };
}
