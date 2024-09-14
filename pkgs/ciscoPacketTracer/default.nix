{
  stdenvNoCC,
  lib,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  dbus,
  dpkg,
  expat,
  fontconfig,
  glib,
  makeDesktopItem,
  makeWrapper,
  qt5,
}:
stdenvNoCC.mkDerivation (args: {
  pname = "ciscoPacketTracer8";

  version = "8.2.2";

  src = builtins.fetchurl {
    url = "https://dn720205.ca.archive.org/0/items/cpt822/CiscoPacketTracer822_amd64_signed.deb";
    sha256 = "sha256:0bgplyi50m0dp1gfjgsgbh4dx2f01x44gp3gifnjqbgr3n4vilkc";
  };

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src $out
    chmod 755 "$out"

    runHook postUnpack
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    dpkg
    makeWrapper
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    dbus
    expat
    fontconfig
    glib
    qt5.qtbase
    qt5.qtmultimedia
    qt5.qtnetworkauth
    qt5.qtscript
    qt5.qtspeech
    qt5.qtwebengine
    qt5.qtwebsockets
  ];

  installPhase = ''
    runHook preInstall

    makeWrapper "$out/opt/pt/bin/PacketTracer" "$out/bin/packettracer8" \
      "''${qtWrapperArgs[@]}" \
      --set QT_QPA_PLATFORMTHEME "" \
      --prefix LD_LIBRARY_PATH : "$out/opt/pt/bin"

    install -D $out/opt/pt/art/app.png $out/share/icons/hicolor/128x128/apps/ciscoPacketTracer8.png

    rm $out/opt/pt/bin/libQt5* -f

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "cisco-pt8.desktop";
      desktopName = "Cisco Packet Tracer 8";
      icon = "ciscoPacketTracer8";
      exec = "packettracer8 %f";
      mimeTypes = ["application/x-pkt" "application/x-pka" "application/x-pkz"];
    })
  ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Network simulation tool from Cisco";
    homepage = "https://www.netacad.com/courses/packet-tracer";
    maintainers = with maintainers; [akibahmed229];
    platforms = ["x86_64-linux"];
    mainProgram = "packettracer8";
  };
})
