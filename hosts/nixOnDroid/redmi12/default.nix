{pkgs, ...}: {
  nixpkgs.overlays = [
    (self: super: {
      openssh = super.openssh.override {
        hpnSupport = true;
        withKerberos = true;
        kerberos = self.libkrb5;
      };
    })
  ];

  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    neovim # or some other editor, e.g. nano or neovim
    fastfetch
    pipes
    android-tools
    btop
    openssh

    # Some common stuff that people expect to have
    procps
    busybox
    killall
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    git
  ];

  terminal.font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf";
  user.shell = "${pkgs.zsh}/bin/zsh";

  # Configure home-manager
  home-manager = {
    config = ./home.nix;
  };
}
