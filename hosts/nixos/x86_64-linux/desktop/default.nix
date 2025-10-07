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
  system, # system info like (system name,path) directly coming from mkSystem functions
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
        ]
        ++ lib.optionals (user == "akib")
        [
          "sops"
          "ngrok"
          "openrazer"
          "intel-gpu"
        ];
    };

  # A lightweight TUI (ncurses-like) display manager for Linux and BSD.
  services.displayManager = {
    ly.enable = true;
    defaultSession = "Niri";
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
    # fail2ban # Intrusion prevention.
    btop # Resource monitor.
    appimage-run # Utility to run AppImage applications.
    tlrc # Command-line tool for TL;DR pages.
    nix-diff # used to compare derivations
    libnotify # Desktop notification
    # stacer # Linux system monitoring tool. # FIXME: broken

    # 2. File Management
    trash-cli # Command-line trash utility.
    # Compression tools.
    zip
    unzip
    p7zip
    # bleachbit # System cleaner.
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
    # libreoffice # Office suite. # FIXME: broken
    figma-linux # Figma design tool.
    # notepadqq # Text editor.

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
    # mediawriter # USB writer for Fedora Media.
    lact # Gui for Graphic card overclocking and other stuff.

    # Development Section

    # 1. Development Tools
    gcc # GNU Compiler Collection.
    cmake # Build system.
    gnumake # Build tool.
    libtool # Library support tool.
    meson # Build system.
    gettext # GNU internationalization and localization library.
    python313 # Python programming language.
    python313Packages.uv # python uv pkgs manager.
    nodejs_24 # JavaScript runtime.
    rustc # Rust programming language and tools.
    cargo # Rust package manager.
    # Development environment tools.
    # devbox
    # distrobox
    yarn # JavaScript package manager.
    jq # JSON processor.
    # Android development tools.
    android-studio
    android-tools
    android-udev-rules
    jdk24 # Java Development Kit
    # jetbrains.pycharm-community # Python IDE. # FIXME: broken
    # jetbrains.idea-community # Java IDE. # FIXME: broken
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
    # handbrake # Video transcoder. # FIXME: broken
    audacity # Audio editor.
    darktable # Photography workflow application.
    ffmpeg-full # Multimedia framework for video/audio processing.
    gst_all_1.gstreamer # Multimedia framework.
    # mpv # Media player.
    kdePackages.kdenlive # Video editor.
    # davinci-resolve # Professional video editing and color grading software.

    # 3. Networking Section
    nmap # Network scanner.
    iperf # Network bandwidth measurement tool.
    tcpdump # Network packet analyzer.
  ];

  # List services that you want to enable:
  services = {
    # disable password auth for openssh
    openssh.settings.PasswordAuthentication = false;
  };

  # Custom nixos modules
  nm = {
    # User management configuration - see modules/custom/nixos/user
    # Per-system user configuration
    setUser = {
      name = user;
      usersPath = ./users/.;
      nixosUsers.enable = true;
      homeUsers.enable = true;

      system = {
        inherit (system) name path;
        inherit desktopEnvironment state-version;
      };
    };

    # Enable virtualisation
    kvm.enable = true;
    # kubernetes
    k8s = {
      enable = true;
      role = "master";
      defaultUser = "akib";
      kubeMasterIP = "192.168.0.111";
    };
    # Docker
    docker = lib.mkIf (user == "akib") {
      enable = true;
      ipvlan.enable = true;
      iptables.enable = false;
      # container
      container = {
        n8n = {
          enable = true;
          defaultUser = user;
        };
        pihole.enable = true;
        jenkins.enable = true;
        portainer.enable = true;
        nextcloud = {
          enable = true;
          defaultUser = user;
        };
      };
    };

    # Full gaming environment
    gaming.enable = false; # FIXME: broken
    # BBR congestion control
    bbr.enable = true;
    # FHS shell and nix-ld support
    fhs.enable = true;
    # (IPC) communication between different applications and system components.
    dbus.enable = true;
    # OBS with default plugins and the virtual camera feature
    obs.enable = true;

    # --- Core Networking Configuration ---
    networking = {
      enable = true;
      defaultGateway = {
        address = "192.168.0.1";
        interface = "enp4s0";
      };
      # Static IPs for physical interfaces
      interfaces = {
        "enp4s0" = ["192.168.0.111/24"];
        "wlp0s20f0u4" = ["192.168.0.179/24"];
      };
    };

    # Samba shares.
    samba = {
      enable = true;
      # Define the drives you want to share
      shares = [
        {device = "sda1";}
        {device = "sda2";}
      ];
    };

    # Openrgb setup.
    openrgb = {
      enable = true;
      motherboard = "intel"; # Explicitly set motherboard type
      # Pass your custom package here
      extraSystemPackages = [
        self.packages.${pkgs.system}.toggleRGB
      ];
    };
  };

  # Open ports in the firewall.
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [3000 8090];
      # allowedUDPPorts = [67 53];
    };
    enableIPv6 = true;
    enableB43Firmware = true;
  };
}
