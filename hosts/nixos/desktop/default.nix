/*
* Host-specific configuration for NixOS systems.
* This is your system's configuration file.
* Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
*/
{
  pkgs,
  user,
  desktopEnvironment,
  state-version,
  hostname,
  self,
  lib,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  imports =
    map mkRelativeToRoot [
      "home-manager/${desktopEnvironment}"
      "home-manager/niri"
    ]
    ++ mkImport {
      path = mkRelativeToRoot "modules/predefiend/nixos";
      ListOfPrograms =
        [
          "stylix"
          "impermanence"
          "gaming"
          "dbus"
          "bbr"
          "fhs"
          "obs"
        ]
        ++ lib.optionals (user == "akib")
        [
          "samba"
          "docker"
          "sops"
          "ngrok"
          "openrgb"
          "openrazer"
          "intel-gpu"
        ];
    }
    ++ mkImport {
      path = mkRelativeToRoot "modules/predefiend/nixos/docker/container";
      ListOfPrograms =
        map (x: x + ".nix")
        (lib.optionals (user == "akib")
          [
            "n8n"
            "nextcloud"
            "portainer"
            "pi-hole"
          ]);
    };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      # self.overlays.discord-overlay
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      permittedInsecurePackages = [
        "qtwebengine-5.15.19" # FIXME
      ];
    };
  };

  # User management configuration ( custom module ) - see modules/custom/nixos/user
  # Per-system user configuration
  setUser = {
    name = "${user}";
    usersPath = ./users/.;
    nixosUsers.enable = true;
    homeUsers.enable = true;
    inherit hostname desktopEnvironment state-version;
  };

  # remove bloat
  documentation.nixos.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # 1. System Utilities
    htop # Interactive process viewer.
    nvme-cli # Utility to manage NVMe SSDs.
    cryptsetup # Disk encryption setup.
    # veracrypt # Disk encryption tool.
    pciutils # Tools for PCI devices.
    fail2ban # Intrusion prevention.
    fastfetch # System information fetcher.
    btop # Resource monitor.
    appimage-run # Utility to run AppImage applications.
    tlrc # Command-line tool for TL;DR pages.
    nix-diff # used to compare derivations

    # 2. File Management
    trash-cli # Command-line trash utility.
    # Compression tools.
    zip
    unzip
    p7zip
    bleachbit # System cleaner.
    obsidian # Note-taking app.
    # rclone # Cloud storage sync tool.
    fzf # Command-line fuzzy finder.
    fuse # Filesystem in Userspace utilities.

    # 3. Communication & Social
    telegram-desktop # Messaging app.
    whatsapp-for-linux # WhatsApp client for Linux.

    # 4. Internet & Networking
    chromium # Web browser.
    qbittorrent # BitTorrent client.
    anydesk # Remote desktop software.
    localsend # Local file transfer tool.
    nextcloud-client # Nextcloud sync client.

    # 5. Productivity
    libreoffice # Office suite.
    figma-linux # Figma design tool.
    notepadqq # Text editor.

    # 6. Gaming & Entertainment
    mangohud # FPS counter and system stats overlay.
    goverlay # Vulkan/OpenGL overlay manager.
    # geekbench # Benchmarking tool.
    kdiskmark # Disk benchmarking tool.
    libadwaita # UI toolkit for GNOME.
    cava # Console-based audio visualizer.
    pipes # Terminal-based game.

    # 7. Miscellaneous
    # gradience # GNOME customization tool.
    # libverto # Event loop abstraction library.
    busybox # Unix utilities in a single executable.
    libinput # Input device management library.
    flatpak # Application sandboxing and distribution framework.
    mediawriter # USB writer for Fedora Media.
    lact # Gui for Graphic card overclocking and other stuff.

    # Development Section

    # 1. Development Tools
    gcc # GNU Compiler Collection.
    cmake # Build system.
    gnumake # Build tool.
    libtool # Library support tool.
    meson # Build system.
    gettext # GNU internationalization and localization library.
    python313Full # Python programming language.
    python313Packages.uv # python uv pkgs manager.
    nodejs_22 # JavaScript runtime.
    rustc # Rust programming language and tools.
    cargo # Rust package manager.
    nixd # Nix language server.
    nil # Nix .
    # Development environment tools.
    devbox
    distrobox
    direnv
    yarn # JavaScript package manager.
    jq # JSON processor.
    # Android development tools.
    android-studio
    android-tools
    android-udev-rules
    jdk21 # Java Development Kit
    jetbrains.pycharm-community # Python IDE.
    jetbrains.idea-community # Java IDE.
    postman # API development environment.
    vscode # Code editor.
    # zed-editor # Code editor.
    git # Version control system.
    # github-desktop # Git client.
    lazygit # Git UI.
    gh # GitHub CLI.
    # self.packages.${pkgs.system}.ciscoPacketTracer

    # 2. Media & Design
    gimp # Image editor.
    # krita # Digital painting software.
    # glaxnimate # Animation editor.
    # inkscape # Vector graphics editor.
    handbrake # Video transcoder.
    audacity # Audio editor.
    # darktable # Photography workflow application.
    ffmpeg-full # Multimedia framework for video/audio processing.
    gst_all_1.gstreamer # Multimedia framework.
    mpv # Media player.
    kdePackages.kdenlive # Video editor.

    # 3. Networking Section
    nmap # Network scanner.
    iperf # Network bandwidth measurement tool.
    tcpdump # Network packet analyzer.
  ];

  # List services that you want to enable:
  services = {
    # disable password auth for openssh
    openssh.settings.PasswordAuthentication = true;
  };

  # Enable virtualisation ( custom module )
  kvm.enable = true;

  # Open ports in the firewall.
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [80 443 22 465 3000 9980 8090 6443];
      allowedUDPPorts = [67 68];
    };
    enableIPv6 = true;
    enableB43Firmware = true;
  };
}
