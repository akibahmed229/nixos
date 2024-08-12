/*
* This is an example configuration file for home-manager.
*
* The file is a Nix expression that evaluates to an attribute set. The
* attribute names are the names of options that home-manager understands.
*/
{
  pkgs,
  self,
  ...
}: let
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # imports from the predefiend modules folder
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms = ["zsh" "tmux" "lf" "git"];
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    xdg-utils
    wl-clipboard
    tree
    hwinfo
    ripgrep
    atuin
    direnv
    neovim

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpeg" = ["image-roll.desktop" "feh.desktop" "org.gnome.eog.desktop"];
        "image/png" = ["image-roll.desktop" "feh.desktop" "org.gnome.eog.desktop"];
        "text/plain" = "nvim.desktop";
        "text/csv" = "nvim.desktop";
        "application/pdf" = ["org.gnome.Evince.desktop" "firefox.desktop" "google-chrome.desktop"];
        "application/zip" = ["org.gnome.FileRoller.desktop" "org.kde.ark.desktop"];
        "application/x-tar" = "org.gnome.FileRoller.desktop";
        "application/x-bzip2" = "org.gnome.FileRoller.desktop";
        "application/x-gzip" = "org.gnome.FileRoller.desktop";
        "application/x-bittorrent" = "org.qbittorrent.qBittorrent.desktop";
        "x-scheme-handler/mailto" = ["gmail.desktop"];
        "x-scheme-handler/tg" = ["userapp-Telegram Desktop-0OI4J2.desktop" "userapp-Telegram Desktop-CUQDL2.desktop" "userapp-Telegram Desktop-7DXZL2.desktop" "userapp-Telegram Desktop-XB3XL2.desktop" "userapp-Telegram Desktop-KLEZM2.desktop" "org.telegram.desktop.desktop"];
        "audio/mp3" = "vlc.desktop";
        "audio/x-matroska" = "vlc.desktop";
        "video/webm" = "vlc.desktop";
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
        "inode/directory" = "pcmanfm.desktop";
      };
    };
    desktopEntries.image-roll = {
      name = "image-roll";
      exec = "${pkgs.image-roll}/bin/image-roll %F";
      mimeType = ["image/*"];
    };
    desktopEntries.gmail = {
      name = "Gmail";
      exec = ''xdg-open "https://mail.google.com/mail/?view=cm&fs=1&to=%u"'';
      mimeType = ["x-scheme-handler/mailto"];
    };
  };
}
