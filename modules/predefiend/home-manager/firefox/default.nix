# nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
{
  pkgs,
  user,
  lib,
  ...
}: {
  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.stdenv.hostPlatform.system}/bin/firefox";
    MOZ_WINDOW_OCCLUSION = "0";
    MOZ_ENABLE_WAYLAND = "1";
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles = {
      # profile for Main user
      ${user} = {
        name = "Akib";
        id = 0;
        search.force = true;
        search.engines = import ./smartkeyword.nix;
        bookmarks = import ./bookmarks.nix;
        settings = import ./settings.nix {inherit lib;};

        # custom css for firefox ui and webpages
        userChrome = builtins.readFile ./userChrome.css;
        userContent = builtins.readFile ./userContent.css;

        extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            # bitwarden
            # tridactyl
            # gsconnect
            # gnome-shell-integration
            # gruvbox-dark-theme
            ublock-origin
            sponsorblock
            darkreader
            youtube-shorts-block
            dearrow
            multi-account-containers
            facebook-container
          ];
        };
      };

      # profile for Other user
      Guest = {
        name = "Guest";
        id = 1;
      };
    };
  };
}
