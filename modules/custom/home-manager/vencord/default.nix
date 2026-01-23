{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.vencord;
in {
  options.hm.vencord = {
    enable = mkEnableOption "Vesktop/Vencord Discord configuration";

    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra Vesktop settings to merge.";
    };

    extraPlugins = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra Vencord plugins to enable or configure.";
    };
  };

  config = mkIf cfg.enable {
    # Ensure vesktop is available in the environment
    home.packages = [pkgs.vesktop];

    programs.vesktop = {
      enable = true;
      package = pkgs.vesktop;

      # Vesktop Base Settings
      settings =
        recursiveUpdate {
          appBadge = false;
          arRPC = true;
          checkUpdates = false;
          customTitleBar = false;
          disableMinSize = true;
          minimizeToTray = true;
          tray = true;
          splashBackground = "#3c3836";
          splashColor = "#2a2725";
          splashTheming = true;
          staticTitle = true;
          hardwareAcceleration = true;
          discordBranch = "stable";
        }
        cfg.extraSettings;

      # Vencord Plugin Settings
      vencord.settings = {
        autoUpdate = false;
        autoUpdateNotification = false;
        notifyAboutUpdates = false;
        useQuickCss = true;
        disableMinSize = true;

        plugins =
          recursiveUpdate {
            # Core Functional Plugins
            MessageLogger = {
              enabled = true;
              ignoreSelf = true;
            };
            FakeNitro = {enabled = true;};
            SilentMessageToggle = {enabled = true;};
            SilentTyping = {enabled = true;};

            # UI Enhancements
            MemberCount = {
              enabled = true;
              memberList = true;
              toolTip = true;
              voiceActivity = true;
            };

            # Media Handling
            FixYoutubeEmbeds = {enabled = true;};
            YoutubeAdblock = {enabled = true;};

            # Spotify Integration
            SpotifyControls = {
              enabled = true;
              hoverControls = false;
            };
            SpotifyCrack = {
              enabled = true;
              noSpotifyAutoPause = true;
              keepSpotifyActivityOnIdle = false;
            };
            SpotifyShareCommands = {enabled = true;};

            # Utility
            ShowHiddenThings = {
              enabled = true;
              showTimeouts = true;
              showInvitesPaused = true;
              showModView = true;
            };
          }
          cfg.extraPlugins;
      };
    };
  };
}
