{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.firefox;

  # Helper to access rycee's addons easily
  addons = pkgs.nur.repos.rycee.firefox-addons;

  defaultPlugins = with addons; [
    ublock-origin
    sponsorblock
    darkreader
    youtube-shorts-block
    dearrow
    multi-account-containers
    facebook-container
  ];
in {
  options.hm.firefox = {
    enable = mkEnableOption "Custom Firefox configuration";

    user = mkOption {
      type = types.str;
      example = "akib";
      description = "The username used for the primary Firefox profile name.";
    };

    scaling = mkOption {
      type = types.str;
      default = "1.0";
      description = "Overall UI/Content scaling (layout.css.devPixelsPerPx). 1.0 is default, 1.2 is 120%.";
    };

    isWayland = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Wayland support variables.";
    };

    extraExtensions = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional Firefox extensions from NUR or pkgs.";
    };
  };

  config = mkIf cfg.enable {
    # 1. MIME Types & Default Applications
    xdg.mimeApps.defaultApplications = let
      browser = ["firefox.desktop"];
    in {
      "text/html" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
    };

    # 2. Environment Variables
    home.sessionVariables = mkMerge [
      {
        DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
        MOZ_WINDOW_OCCLUSION = "0";
      }
      (mkIf cfg.isWayland {
        MOZ_ENABLE_WAYLAND = "1";
      })
    ];

    # 3. Firefox Program Settings
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;

      profiles = {
        # Primary User Profile
        "${cfg.user}" = {
          name = cfg.user;
          id = 0;
          isDefault = true;

          # UI Customization
          userChrome = mkIf (builtins.pathExists ./userChrome.css) (builtins.readFile ./userChrome.css);
          userContent = mkIf (builtins.pathExists ./userContent.css) (builtins.readFile ./userContent.css);

          # Search & Bookmarks
          search = {
            force = true;
            engines = import ./_smartkeyword.nix;
          };
          bookmarks = import ./_bookmarks.nix;

          # Settings merging
          settings = import ./_settings.nix {inherit lib;};

          extensions.packages = defaultPlugins ++ cfg.extraExtensions;
        };

        # Secondary Guest Profile
        Guest = {
          name = "Guest";
          id = 1;
          settings = {
            "layout.css.devPixelsPerPx" = cfg.scaling;
            "browser.privatebrowsing.autostart" = true;
          };
        };
      };
    };
  };
}
