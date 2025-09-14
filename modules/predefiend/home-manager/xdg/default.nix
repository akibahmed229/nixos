{
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
        "x-scheme-handler/tg" = ["userapp-Telegram Desktop-0OI4J2.desktop" "userapp-Telegram Desktop-CUQDL2.desktop" "userapp-Telegram Desktop-7DXZL2.desktop" "userapp-Telegram Desktop-XB3XL2.desktop" "userapp-Telegram Desktop-KLEZM2.desktop" "org.telegram.desktop.desktop"];
        "audio/mp3" = "vlc.desktop";
        "audio/x-matroska" = "vlc.desktop";
        "video/webm" = "vlc.desktop";
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
        "inode/directory" = "pcmanfm.desktop";
      };
    };

    /*
    - Example
    # desktopEntries.gmail = {
          name = "Gmail";
          exec = ''xdg-open "https://mail.google.com/mail/?view=cm&fs=1&to=%u"'';
          mimeType = ["x-scheme-handler/mailto"];
        };
    */
  };
}
