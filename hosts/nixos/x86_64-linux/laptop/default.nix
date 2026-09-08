{
  inputs,
  user,
  system,
  state-version,
  pkgs,
  ...
}: {
  imports = [
    # Import the wsl module directly from your flake inputs
    inputs.nixos-wsl.nixosModules.default
  ];

  # ---------------------------------------- Custom Nixos Modules ----------------------------------------------------
  nm = {
    # ------------------- Per-system user configuration -----------------------
    setUser = {
      # see modules/custom/nixos/user
      name = user;
      usersPath = ./users/.;
      nixosUsers.en = false;
      homeUsers.en = true;

      system = {
        inherit (system) name path;
        inherit state-version;
      };
    };
  };

  # Basic WSL Configuration
  wsl = {
    enable = true;
    usbip.enable = true; # Automatically provisions required binaries for usbipd-win
    defaultUser = user; # Uses "akib" from your flake.nix

    usbip.autoAttach = [
      "1-15"
    ];

    wslConf = {
      boot = {
        systemd = true;
      };

      automount = {
        enabled = true;
        root = "/mnt";
        options = "metadata,uid=1003,gid=1003,umask=077,fmask=11,case=off";
        mountFsTab = true;
      };

      interop = {
        enabled = true;
        appendWindowsPath = true;
      };

      network = {
        hostname = system.name;
        generateHosts = true;
        generateResolvConf = true;
      };
    };

    environment.systemPackages = with pkgs; [
      gcc # GNU Compiler Collection.
      cmake # Build system.
      gnumake # Build tool.
      libtool # Library support tool.
      meson # Build system.
      gettext # GNU internationalization and localization library.
      python314 # Python programming language.
      python314Packages.uv # python uv pkgs manager.
      nodejs_26 # JavaScript runtime.
      rustc # Rust programming language and tools.
      cargo # Rust package manager.
      # Development environment tools.
      # devbox
      # distrobox
      # yarn # JavaScript package manager.
      jq # JSON processor.
      sqlite
      # Android development tools.
      # android-studio
      android-tools
      jdk25 # Java Development Kit
      # jetbrains.pycharm # Python IDE.
      # jetbrains.idea # Java IDE.
      # godot # Multi-platform 2D and 3D game engine
      postman # API development environment.
      # vscode # Code editor.
      # zed-editor # Code editor.
      git # Version control system.
      # github-desktop # Git client.
      lazygit # Git UI.
      gh # GitHub CLI.
      # self.packages.${pkgs.stdenv.hostPlatform.system}.ciscoPacketTracer
      dotnetCorePackages.sdk_10_0
    ];
  };

  # Optional but recommended for WSL:
  wsl.startMenuLaunchers = true;
}
