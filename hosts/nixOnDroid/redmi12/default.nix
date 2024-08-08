{pkgs, ...}: {
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim # or some other editor, e.g. nano or neovim

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
  programs = {
    # Enable ADB for Android and other stuff.
    adb.enable = true;
    zsh.enable = true;
  };

  # Configure home-manager
  home-manager = {
    config = ./home.nix;
  };
}
