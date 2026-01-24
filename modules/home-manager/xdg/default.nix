{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.xdg;
in {
  options.hm.xdg = {
    enable = mkEnableOption "XDG user directories and mime associations";

    createDirs = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically create the XDG user directories.";
    };

    defaultApps = mkOption {
      type = types.attrsOf (types.either types.str (types.listOf types.str));
      default = {
        "image/jpeg" = ["org.gnome.eog.desktop" "image-roll.desktop" "feh.desktop"];
        "image/png" = ["org.gnome.eog.desktop" "image-roll.desktop" "feh.desktop"];
        "text/plain" = "nvim.desktop";
        "text/csv" = "nvim.desktop";
        "application/pdf" = ["org.gnome.Evince.desktop" "firefox.desktop" "google-chrome.desktop"];
        "application/zip" = ["org.gnome.FileRoller.desktop" "org.kde.ark.desktop"];
        "application/x-tar" = "org.gnome.FileRoller.desktop";
        "application/x-bzip2" = "org.gnome.FileRoller.desktop";
        "application/x-gzip" = "org.gnome.FileRoller.desktop";
        "application/x-bittorrent" = "org.qbittorrent.qBittorrent.desktop";
        "x-scheme-handler/mailto" = ["gmail.desktop"];
        "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
        "audio/mp3" = "vlc.desktop";
        "audio/x-matroska" = "vlc.desktop";
        "video/webm" = "vlc.desktop";
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
        "inode/directory" = "pcmanfm.desktop";
      };
      description = "Default applications for specific mime types.";
    };
  };

  config = mkIf cfg.enable {
    xdg = {
      enable = true;

      userDirs = {
        enable = true;
        createDirectories = cfg.createDirs;
      };

      mime.enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = cfg.defaultApps;
      };

      desktopEntries.gmail = {
        name = "Gmail";
        exec = ''xdg-open "https://mail.google.com/mail/?view=cm&fs=1&to=%u"'';
        mimeType = ["x-scheme-handler/mailto"];
        icon = "gmail"; # Assumes you have an icon named gmail in your theme
        terminal = false;
        categories = ["Network" "Email"];
      };
    };
  };
}
