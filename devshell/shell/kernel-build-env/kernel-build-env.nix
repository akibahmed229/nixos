{ pkgs ? import <nixpkgs> { } }:

(pkgs.buildFHSUserEnv {
  name = "kernel-build-env";
  targetPkgs = pkgs: (with pkgs;
    [
      pkg-config
      ncurses
      linuxHeaders
      util-linux
      e2fsprogs
      jfsutils
      reiserfsprogs
      binutils
      xfsprogs
      squashfs-tools-ng
      btrfs-progs
      pcmciaUtils
      linuxquota
      PPP
      nfs-utils
      procps
      oprofile
      udev
      grub
      mcelog
      iptables
      openssl
      bc
      Sphinx
      qt5.qtbase
      # new gcc usually causes issues with building kernel so use an old one
      pkgsCross.aarch64-multiplatform.gcc12Stdenv.cc
      (hiPrio gcc12)
    ]
    ++ pkgs.linux.nativeBuildInputs);
  runScript = pkgs.writeScript "init.sh" ''
    export ARCH=arm64
    export hardeningDisable=all
    export CROSS_COMPILE=aarch64-unknown-linux-gnu-
    export PKG_CONFIG_PATH="${pkgs.ncurses.dev}/lib/pkgconfig:${pkgs.qt5.qtbase.dev}/lib/pkgconfig"
    export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/lib/qt-${pkgs.qt5.qtbase.version}/plugins"
    export QT_QPA_PLATFORMTHEME=qt5ct
    exec "${pkgs.zsh}/bin/zsh"
  '';
}).env
