{
  description = "Kernel Development Environment (ARM64 cross-compile)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; # or your preferred channel
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux"; # host system (adjust if needed)
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };
  in {
    devShells.${system}.default = pkgs.buildFHSEnv {
      name = "kernel-build-env";

      targetPkgs = pkgs: (with pkgs;
        [
          pkg-config
          ncurses
          qt5.qtbase
          binutils
          linuxHeaders
          libelf
          flex
          bison
          gdb
          strace
          # old GCC for kernel
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
    };
  };
}
