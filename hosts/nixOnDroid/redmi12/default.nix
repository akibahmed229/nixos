{
  pkgs,
  user,
  ...
}: {
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    neovim # or some other editor, e.g. nano or neovim
    fastfetch
    pipes

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

  terminal.font = "${pkgs.jetbrains-mono}/share/fonts/TTF/JetBrainsMono-Regular.ttf";

  user.shell = "${pkgs.zsh}/bin/zsh";
  user.userName = "${user}";

  # Configure home-manager
  home-manager = {
    config = ./home.nix;
  };
}
