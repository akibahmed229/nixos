{pkgs, ...}: {
  home.packages = with pkgs; [
    vesktop # for screen sharing on wayland
  ];

  programs.vesktop = {
    enable = true;
    package = pkgs.vesktop;

    # Vesktop’s own settings
    settings = {
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
    };

    # Vencord plugin + feature settings
    vencord.settings = {
      autoUpdate = false;
      autoUpdateNotification = false;
      notifyAboutUpdates = false;
      useQuickCss = true;
      disableMinSize = true;
      plugins = {
        MessageLogger = {
          enabled = true;
          ignoreSelf = true;
        };
        FakeNitro = {
          enabled = true;
        };
        SilentMessageToggle = {
          enabled = true;
        };
        SilentTyping = {
          enabled = true;
        };
        MemberCount = {
          enabled = true;
          memberList = true;
          toolTip = true;
          voiceActivity = true;
        };

        FixYoutubeEmbeds = {
          enabled = true;
        };
        YoutubeAdblock = {
          enabled = true;
        };

        SpotifyControls = {
          enabled = true;
          hoverControls = false;
        };
        SpotifyCrack = {
          enabled = true;
          noSpotifyAutoPause = true;
          keepSpotifyActivityOnIdle = false;
        };
        SpotifyShareCommands = {
          enabled = true;
        };

        ShowHiddenThings = {
          enabled = true;
          showTimeouts = true;
          showInvitesPaused = true;
          showModView = true;
        };
      };
    };
  };
}
