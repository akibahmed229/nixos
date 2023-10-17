{ pkgs, inputs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.yurii = {

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
          name = "wikipedia";
          tags = [ "wiki" ];
          keyword = "wiki";
          url = "https://en.wikipedia.org/wiki/Main_Page";
        }
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
        gnome-shell-integration
        gruvbox-dark-theme
      ];

    };
  };
}

