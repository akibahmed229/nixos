{
  user,
  system,
  ...
}: {
  # ── Host-Specific Settings ───────────────────────────────────────────────────

  # Set the hostname and computer name.
  networking.hostName = system.name;

  # ── User Account ─────────────────────────────────────────────────────────────
  # Define your user account on this machine.
  # Replace 'akib' with your actual username if it's different.
  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };
  system.primaryUser = user;

  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
      DisableAllAnimations = true;
      NewWindowTarget = "PfDe";
      NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowStatusBar = true;
      ShowPathbar = true;
      WarnOnEmptyTrash = false;
    };
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.HIToolbox" = {
      # Completely disable Caps Lock functionality
      AppleFnUsageType = 1; # Enable Fn key functionality
      AppleKeyboardUIMode = 3;
      # Disable Caps Lock toggle entirely
      AppleSymbolicHotKeys = {
        "60" = {
          enabled = false; # Disable Caps Lock toggle hotkey
        };
      };
      # Override modifier key behavior to prevent Caps Lock from functioning
      AppleModifierKeyRemapping = {
        "1452-630-0" = {
          # Map Caps Lock (key code 57/0x39) to nothing (disable it)
          HIDKeyboardModifierMappingSrc = 30064771129; # Caps Lock
          HIDKeyboardModifierMappingDst = 30064771299; # No Action
        };
      };
    };
    "com.apple.dock" = {
      autohide = false;
      launchanim = false;
      static-only = false;
      show-recents = false;
      show-process-indicators = true;
      orientation = "left";
      tilesize = 36;
      minimize-to-application = true;
      mineffect = "scale";
      enable-window-tool = false;
    };
    "com.apple.ActivityMonitor" = {
      OpenMainWindow = true;
      IconType = 5;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };
    "com.apple.Safari" = {
      # Privacy: don’t send search queries to Apple
      UniversalSearchEnabled = false;
      SuppressSearchSuggestions = true;
    };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      # Check for software updates daily, not just once per week
      ScheduleFrequency = 1;
      # Download newly available updates in background
      AutomaticDownload = 1;
      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };
    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;
    # Turn on app auto-update
    "com.apple.commerce".AutoUpdate = true;
    "com.googlecode.iterm2".PromptOnQuit = false;
    "com.google.Chrome" = {
      AppleEnableSwipeNavigateWithScrolls = true;
      DisablePrintPreview = true;
      PMPrintingExpandedStateForPrint2 = true;
    };
  };

  # ── Home Manager Setup ───────────────────────────────────────────────────────
  # Integrate Home Manager for this user.
  # This assumes you have home-manager as an input in your flake.
  home-manager = {
    users.${user} = import ./home.nix; # Points to your user-specific dotfiles config
  };

  # ── GUI Applications via Homebrew Casks ──────────────────────────────────────
  # Install applications that are specific to this iMac.
  homebrew.casks = [
    # "firefox"
    "visual-studio-code"
    "iterm2"
    "spotify"
    "discord"
    "rectangle" # A great window manager
  ];

  # You can also install specific command-line tools for this machine.
  homebrew.brews = ["imagemagick"];
}
