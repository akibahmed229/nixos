# nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
{ pkgs, inputs, lib, ... }:

{
  xdg.mimeApps.defaultApplications = {
    "text/html" = "brave-browser.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
  };

  programs.firefox = {
    enable = true;
    profiles.akib = {

      search.engines = {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];

          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
      };
      search.force = true;

      bookmarks = [
        {
          name = "youtube";
          tags = [ "video" ];
          keyword = "yt";
          url = "https://www.youtube.com/";
        }
        {
          name = "github";
          tags = [ "git" ];
          keyword = "gh";
          url = "github.com/akibahmed229";
        }
        {
          name = "reddit";
          tags = [ "social" ];
          keyword = "r";
          url = "https://www.reddit.com/";
        }
        {
          name = "DIU Blender";
          tags = [ "education" ];
          keyword = "varsity";
          url = "https://elearn.daffodilvarsity.edu.bd/";
        }
        {
          name = "DIU Strudent Portal";
          tags = [ "education" ];
          keyword = "portal";
          url = "http://studentportal.diu.edu.bd";
        }
        {
          name = "Gmail";
          tags = [ "email" ];
          keyword = "mail";
          url = "https://mail.google.com/mail/u/0/#inbox";
        }
        {
          name = "Nix Packages";
          tags = [ "nix" ];
          keyword = "nixpkgs";
          url = "https://search.nixos.org/packages";
        }
        {
          name = "Nix Home-Manager options";
          tags = [ "nix" ];
          keyword = "nix home-manager options";
          url = "https://mipmip.github.io/home-manager-option-search/";
        }
        {
          name = "Chat Gpt";
          tags = [ "chat" "gpt" "ai" ];
          keyword = "chat";
          url = "https://chat.openai.com/";
        }
        {
          name = "Google Bird";
          tags = [ "ai" "google" "bird" ];
          keyword = "chat";
          url = "https://bard.google.com/chat";
        }
        {
          name = "Binge Ai";
          tags = [ "ai" "binge" ];
          keyword = "binge";
          url = "https://www.bing.com/search?q=Bing+AI&showconv=1";
        }
      ];

      settings = {
        "media.mediasource.enabled" = true;
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
      };

      userChrome = ''                         
        /* some css */                        
      '';

      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        bitwarden
        ublock-origin
        sponsorblock
        darkreader
        tridactyl
        youtube-shorts-block
        gsconnect
        #gnome-shell-integration
        gruvbox-dark-theme
      ];

    };
  };
}

