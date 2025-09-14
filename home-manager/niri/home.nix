{
  pkgs,
  lib,
  config,
  ...
}: let
  niriConfig = "$FLAKE_DIR/home-manager/niri/niri";
  niriTarget = "${config.home.homeDirectory}/.config/niri";
in {
  home.packages = with pkgs; [
    # For niri
    xwayland-satellite
    wl-clipboard
    cliphist
  ];

  xdg.portal = {
    # Required for flatpak with window managers and for file browsing
    enable = true;
    config = {
      common = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
      niri = {
        # Niri-specific section to assign portals properly
        default = ["gtk" "gnome"];
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr # Explicitly add for fallback if needed
    ];
  };

  home.activation.symlinkNiriWMConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn "${niriConfig}" "${niriTarget}"
  '';
}
