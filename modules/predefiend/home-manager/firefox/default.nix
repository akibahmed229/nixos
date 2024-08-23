# nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
{
  pkgs,
  unstable,
  user,
  inputs,
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
    DEFAULT_BROWSER = "${pkgs.system}/bin/firefox";
  };

  programs.firefox = {
    enable = true;
    package = unstable.${pkgs.system}.firefox;
    profiles.${user} = {
      search.engines = {
        "Nix Packages" = {
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];

          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@np"];
        };
      };
      search.force = true;

      bookmarks = [
        {
          name = "youtube";
          tags = ["video"];
          keyword = "yt";
          url = "https://www.youtube.com/";
        }
        {
          name = "github";
          tags = ["git"];
          keyword = "gh";
          url = "github.com/akibahmed229";
        }
        {
          name = "reddit";
          tags = ["social"];
          keyword = "r";
          url = "https://www.reddit.com/";
        }
        {
          name = "DIU Blender";
          tags = ["education"];
          keyword = "varsity";
          url = "https://elearn.daffodilvarsity.edu.bd/";
        }
        {
          name = "DIU Strudent Portal";
          tags = ["education"];
          keyword = "portal";
          url = "http://studentportal.diu.edu.bd";
        }
        {
          name = "Gmail";
          tags = ["email"];
          keyword = "mail";
          url = "https://mail.google.com/mail/u/0/#inbox";
        }
        {
          name = "Nix Packages";
          tags = ["nix" "pkgs"];
          keyword = "nixpkgs";
          url = "https://search.nixos.org/packages";
        }
        {
          name = "Nix Home-Manager options";
          tags = ["nix" "home-manager"];
          keyword = "home-manager";
          url = "https://mipmip.github.io/home-manager-option-search/";
        }
        {
          name = "noogle";
          tags = ["nix" "lib"];
          keyword = "nix-lib";
          url = "https://noogle.dev/";
        }
        {
          name = "Chat Gpt";
          tags = ["chat" "gpt" "ai"];
          keyword = "chat";
          url = "https://chat.openai.com/";
        }
        {
          name = "Google Bird";
          tags = ["ai" "google" "bird" "gemini"];
          keyword = "chat";
          url = "https://gemini.google.com/";
        }
        {
          name = "Binge Ai";
          tags = ["ai" "binge"];
          keyword = "binge";
          url = "https://www.bing.com/search?q=Bing+AI&showconv=1";
        }
      ];

      settings = {
        "media.mediasource.enabled" = true;
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        "layout.css.has-selector.enabled" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
      };

      # custom css for firefox ui and webpages
      userChrome = builtins.readFile ./userChrome.css;
      userContent = builtins.readFile ./userContent.css;

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
