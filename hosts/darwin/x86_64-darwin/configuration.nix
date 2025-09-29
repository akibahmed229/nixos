{
  pkgs,
  user,
  self,
  ...
}: {
  # ── Global Settings ──────────────────────────────────────────────────────────
  # System-wide settings and packages.
  # touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # system defaults and preferences
  system = {
    # It's crucial to set this.
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;

    startup.chime = false;

    defaults = {
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };

      finder = {
        AppleShowAllFiles = true; # hidden files
        AppleShowAllExtensions = true; # file extensions
        _FXShowPosixPathInTitle = true; # title bar full path
        ShowPathbar = true; # breadcrumb nav at bottom
        ShowStatusBar = true; # file count & disk space
        FXPreferredViewStyle = "Nlsv";
      };

      NSGlobalDomain = {
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Always";
        NSUseAnimatedFocusRing = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
        NSDocumentSaveNewDocumentsToCloud = false;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 25;
        KeyRepeat = 2;
        "com.apple.mouse.tapBehavior" = 1;
        NSWindowShouldDragOnGesture = true;
      };

      LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
    };
  };

  # Font Setting
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      font-awesome
      lohit-fonts.bengali
      jetbrains-mono
      source-han-sans
      nerd-fonts.jetbrains-mono
    ];
  };

  # programs.nix-index.enable = true;

  # Set your timezone.
  time.timeZone = "Asia/Dhaka";

  # Install some essential command-line tools.
  environment.systemPackages = with pkgs; [
    git
    coreutils # Provides GNU utilities like `gsha256sum`
    wget
    neovim
  ];

  # ── User Environment ─────────────────────────────────────────────────────────
  # Define default settings for users.

  # ── Homebrew ─────────────────────────────────────────────────────────────────
  # Enable and configure Homebrew for GUI apps (casks) and CLI tools (brews).
  # This is managed by Nix, so you don't need to run `brew` commands manually.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # Thoroughly uninstall old versions
    };
    # You can add common brews/casks for all your Macs here.
    # For example:
    # taps = [ "homebrew/cask-fonts" ];
    # brews = [ "htop" ];
    # casks = [ "font-fira-code-nerd-font" ];
  };

  # ── Security ─────────────────────────────────────────────────────────────────

  # You can add more security settings here.
  # For example, to enable Gatekeeper:
  # security.gatekeeper.enable = true;

  # Enable flakes and the new nix command.
  nix = {
    enable = false;
    settings = {
      # given the users in this list the right to specify additional substituters via:
      #    1. `nixConfig.substituters` in `flake.nix`
      trusted-users = [user];

      experimental-features = ["nix-command" "flakes"];
    };
  };
}
