{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.theme;
in {
  options = {
    theme = {
      enable = lib.mkEnableOption "Enable GTK and QT theme";
    };
  };

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;
      cursorTheme.name = "Bibata-Modern-Classic";
      cursorTheme.package = pkgs.bibata-cursors;
      theme.package = pkgs.adw-gtk3;
      theme.name = "adw-gtk3-dark";
      iconTheme.package = pkgs.gruvbox-dark-icons-gtk;
      iconTheme.name = "oomox-gruvbox-dark";
    };

    home = {
      pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        size = 24;
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
      };
    };

    qt = {
      enable = true;
      # platform theme "gtk" or "gnome"
      platformTheme.name = "gtk3";
      # name of the qt theme
      style.name = "adwaita-dark";

      # detected automatically:
      # adwaita, adwaita-dark, adwaita-highcontrast,
      # adwaita-highcontrastinverse, breeze,
      # bb10bright, bb10dark, cde, cleanlooks,
      # gtk2, motif, plastique
      # package to use
      style.package = pkgs.adwaita-qt;
    };
  };
}
