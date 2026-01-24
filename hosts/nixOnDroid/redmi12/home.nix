{
  config,
  pkgs,
  state-version,
  ...
}: {
  hm = {
    zsh.enable = true;
    tmux.enable = true;
    lf.enable = true;
  };

  home = {
    packages = with pkgs; [
      # Core
      zsh
      git
      direnv
    ];
    stateVersion = "24.05"; # Please read the comment before changing.
  };

  programs = {
    ssh = {
      enable = true;
      package = pkgs.openssh;
    };

    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = pkgs.atuin;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "https://api.atuin.sh";
        search_mode = "prefix";
      };
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      music = "${config.home.homeDirectory}/Media/Music";
      videos = "${config.home.homeDirectory}/Media/Videos";
      pictures = "${config.home.homeDirectory}/Media/Pictures";
      templates = "${config.home.homeDirectory}/Templates";
      download = "${config.home.homeDirectory}/Downloads";
      documents = "${config.home.homeDirectory}/Documents";
      desktop = null;
      publicShare = null;
      extraConfig = {
        XDG_DOTFILES_DIR = "${config.home.homeDirectory}/.dotfiles";
        XDG_ARCHIVE_DIR = "${config.home.homeDirectory}/Archive";
        XDG_ORG_DIR = "${config.home.homeDirectory}/Org";
        XDG_BOOK_DIR = "${config.home.homeDirectory}/Media/Books";
      };
    };
    mime.enable = true;
    mimeApps.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  news.display = "silent";
  programs.home-manager.enable = true;
}
