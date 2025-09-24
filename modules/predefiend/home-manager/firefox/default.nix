# nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
{
  pkgs,
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
    package = pkgs.firefox;
    profiles = {
      # profile for Main user
      ${user} = {
        name = "Akib";
        id = 0;
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

        bookmarks = {
          force = true;
          settings = [
            {
              name = "NixOS";
              bookmarks = [
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
                  keyword = "noogle";
                  url = "https://noogle.dev/";
                }
              ];
            }
            {
              name = "AI";
              bookmarks = [
                {
                  name = "Google Gemini";
                  keyword = "gemini";
                  url = "https://gemini.google.com/";
                }
                {
                  name = "Grok";
                  keyword = "grok";
                  url = "https://grok.com/";
                }
                {
                  name = "ChatGPT";
                  keyword = "gpt";
                  url = "https://chat.openai.com/";
                }
                {
                  name = "Bing AI";
                  keyword = "bing";
                  url = "https://www.bing.com/search?q=Bing+AI&showconv=1";
                }
              ];
            }
            {
              name = "Personal";
              bookmarks = [
                {
                  name = "YouTube";
                  keyword = "yt";
                  url = "https://www.youtube.com/";
                }
                {
                  name = "GitHub";
                  keyword = "gh";
                  url = "https://github.com/akibahmed229";
                }
                {
                  name = "Reddit";
                  keyword = "r";
                  url = "https://www.reddit.com/";
                }
                {
                  name = "Gmail";
                  keyword = "mail";
                  url = "https://mail.google.com/mail/u/0/#inbox";
                }
              ];
            }
            {
              name = "Varsity";
              bookmarks = [
                {
                  name = "DIU Blender";
                  url = "https://elearn.daffodilvarsity.edu.bd/";
                }
                {
                  name = "DIU Student Portal";
                  url = "http://studentportal.diu.edu.bd";
                }
              ];
            }
            {
              name = "Dev";
              bookmarks = [
                # --- Docs & References ---
                {
                  name = "MDN Docs";
                  url = "https://developer.mozilla.org/";
                }
                {
                  name = "DevDocs";
                  url = "https://devdocs.io/";
                }
                {
                  name = "Stack Overflow";
                  url = "https://stackoverflow.com/";
                }
                {
                  name = "NixOS Manual";
                  url = "https://nixos.org/manual/nixos/unstable/";
                }
                {
                  name = "Docker Docs";
                  url = "https://docs.docker.com/";
                }
                {
                  name = "Kubernetes Docs";
                  url = "https://kubernetes.io/docs/";
                }

                # --- Full Stack / DevOps ---
                {
                  name = "GitHub";
                  url = "https://github.com/";
                }
                {
                  name = "GitLab";
                  url = "https://gitlab.com/";
                }
                {
                  name = "PostgreSQL Docs";
                  url = "https://www.postgresql.org/docs/";
                }
                {
                  name = "Node.js Docs";
                  url = "https://nodejs.org/docs/latest/api/";
                }
                {
                  name = "Flutter Docs";
                  url = "https://docs.flutter.dev/";
                }

                # --- News / Tech Updates ---
                {
                  name = "Hacker News";
                  url = "https://news.ycombinator.com/";
                }
                {
                  name = "Dev.to";
                  url = "https://dev.to/";
                }
              ];
            }
          ];
        };

        settings = {
          # Enable Dev Tool
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;

          # Example Section (yours)
          "media.mediasource.enabled" = true;
          "dom.security.https_only_mode" = true;
          "browser.download.panel.shown" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "svg.context-properties.content.enabled" = true;
          "layout.css.has-selector.enabled" = true;
          "identity.fxaccounts.enabled" = false;
          "signon.rememberSignons" = false;

          # --- Theme Adjustments ---
          "sidebar.verticalTabs" = true;
          "sidebar.visibility" = "always-show";
          "sidebar.expandOnHover" = true;
          "browser.uidensity" = 1;
          "sidebar.revamp" = false;
          "widget.windows.mica.popups" = 0;
          "browser.compactmode.show" = true;
          "widget.non-native-theme.scrollbar.style" = 2;
          "gfx.font_rendering.cleartype_params.rendering_mode" = 5;
          "gfx.font_rendering.cleartype_params.cleartype_level" = 100;
          "gfx.font_rendering.directwrite.use_gdi_table_loading" = false;

          # --- Privacy ---
          "breakpad.reportURL" = "";
          "app.normandy.api_url" = "";
          "app.normandy.enabled" = false;
          "browser.uitour.enabled" = false;
          "toolkit.coverage.opt-out" = true;
          "browser.urlbar.trimHttps" = true;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "browser.attribution.enabled" = false;
          "toolkit.coverage.endpoint.base" = "";
          "toolkit.telemetry.server" = "data:,";
          "privacy.userContext.ui.enabled" = true;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "network.auth.subresource-http-auth-allow" = 2;
          "browser.helperApps.deleteTempFileOnExit" = true;
          "network.http.referer.XOriginTrimmingPolicy" = 0;
          "browser.tabs.crashReporting.sendReport" = false;
          "app.shield.optoutstudies.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.pioneer-new-studies-available" = false;
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

          # --- Performance ---
          "network.prefetch-next" = true;
          "gfx.canvas.accelerated" = true;
          "network.http.rcwn.enabled" = true;
          "media.cache_readahead_limit" = 60;
          "media.cache_resume_threshold" = 30;
          "layers.gpu-process.enabled" = true;
          "media.memory_cache_max_size" = 8192;
          "network.dns.disablePrefetch" = true;
          "image.mem.decode_bytes_at_a_time" = 16384;
          "media.hardware-video-decoding.enabled" = true;
          "network.predictor.enable-hover-on-ssl" = true;
          "network.dns.disablePrefetchFromHTTPS" = false;
          "dom.script_loader.bytecode_cache.strategy" = 0;
          "media.memory_caches_combined_limit_kb" = 524288;
          "layout.css.grid-template-masonry-value.enabled" = false;

          # --- Annoyances ---
          "browser.ml.enable" = false;
          "browser.ml.chat.sidebar" = false;
          "browser.ml.chat.enabled" = false;
          "browser.ml.chat.shortcuts" = false;
          "extensions.pocket.enabled" = false;
          "full-screen-api.warning.delay" = -1;
          "full-screen-api.warning.timeout" = 0;
          "extensions.getAddons.showPane" = false;
          "browser.ml.chat.shortcuts.custom" = false;
          "browser.privatebrowsing.vpnpromourl" = "";
          "browser.preferences.moreFromMozilla" = false;
          "full-screen-api.transition-duration.enter" = "0 0";
          "full-screen-api.transition-duration.leave" = "0 0";
          "extensions.htmlaboutaddons.recommendations.enabled" = false;

          # --- Smooth Scrolling ---
          "general.smoothScroll" = true;
          "apz.overscroll.enabled" = true;
          "mousewheel.default.delta_multiplier_y" = 300;
          "general.smoothScroll.msdPhysics.enabled" = true;
          "general.smoothScroll.currentVelocityWeighting" = "1";
          "general.smoothScroll.stopDecelerationWeighting" = "1";
          "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
          "general.smoothScroll.msdPhysics.regularSpringConstant" = 650;
          "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = "2";
          "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
          "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
          "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 600;

          # --- Miscellaneous ---
          "media.eme.enabled" = true;
          "image.jxl.enabled" = true;
          "image.avif.enabled" = true;
          "editor.truncate_user_pastes" = true;
          "browser.urlbar.suggest.calculator" = true;
          "browser.urlbar.unitConversion.enabled" = true;
          "browser.bookmarks.openInTabClosesMenu" = false;
          "network.protocol-handler.expose.magnet" = false;
          "browser.translations.newSettingsUI.enable" = true;
          "layout.word_select.eat_space_to_next_word" = false;
          "browser.download.open_pdf_attachments_inline" = true;
          "browser.urlbar.untrimOnUserInteraction.featureGate" = true;
        };

        # custom css for firefox ui and webpages
        userChrome = builtins.readFile ./userChrome.css;
        userContent = builtins.readFile ./userContent.css;

        extensions = {
          packages = with inputs.firefox-addons.packages."x86_64-linux"; [
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
