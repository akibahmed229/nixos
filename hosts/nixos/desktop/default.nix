/*
* Host-specific configuration for NixOS systems.
* This is your system's configuration file.
* Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
*/
{
  pkgs,
  user,
  desktopEnvironment,
  self,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  imports =
    map mkRelativeToRoot [
      "home-manager/${desktopEnvironment}"
      "modules/predefiend/nixos/docker/container/pi-hole.nix"
      "modules/predefiend/nixos/docker/container/nextcloud.nix"
      "modules/predefiend/nixos/docker/container/portainer.nix"
    ]
    ++ mkImport {
      path = mkRelativeToRoot "modules/predefiend/nixos";
      ListOfPrograms = ["sops" "stylix" "impermanence" "mysql" "postgresql" "kubernetes" "docker" "gaming" "bbr" "samba" "fhs" "intel-gpu" "openrazer" "openrgb" "obs" "cloudflared"];
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
    };
  };

  # remove bloat
  documentation.nixos.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # 1. System Utilities
    htop # Interactive process viewer.
    nvme-cli # Utility to manage NVMe SSDs.
    gparted # Partition editor.
    cryptsetup # Disk encryption setup.
    veracrypt # Disk encryption tool.
    i2c-tools # Utilities for I2C devices.
    pciutils # Tools for PCI devices.
    fail2ban # Intrusion prevention.
    fastfetch # System information fetcher.
    btop # Resource monitor.
    appimage-run # Utility to run AppImage applications.
    tlrc # Command-line tool for TL;DR pages.

    # 2. File Management
    trash-cli # Command-line trash utility.
    # Compression tools.
    zip
    unzip
    p7zip
    ranger # Console file manager.
    bleachbit # System cleaner.
    obsidian # Note-taking app.
    rclone # Cloud storage sync tool.
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
    gradience # GNOME customization tool.
    libverto # Event loop abstraction library.
    busybox # Unix utilities in a single executable.
    libinput # Input device management library.
    atuin # history management tool for cli
    flatpak # Application sandboxing and distribution framework.

    # Development Section

    # 1. Development Tools
    gcc # GNU Compiler Collection.
    cmake # Build system.
    gnumake # Build tool.
    libtool # Library support tool.
    meson # Build system.
    gettext # GNU internationalization and localization library.
    python312Full # Python programming language.
    nodejs_22 # JavaScript runtime.
    rustc # Rust programming language and tools.
    cargo # Rust package manager.
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
    zed-editor # Code editor.
    git # Version control system.
    github-desktop # Git client.
    lazygit # Git UI.
    gh # GitHub CLI.
    self.packages.${pkgs.system}.ciscoPacketTracer

    # 2. Media & Design
    gimp # Image editor.
    krita # Digital painting software.
    glaxnimate # Animation editor.
    inkscape # Vector graphics editor.
    handbrake # Video transcoder.
    audacity # Audio editor.
    darktable # Photography workflow application.
    ffmpeg_6 # Multimedia framework for video/audio processing.
    gst_all_1.gstreamer # Multimedia framework.
    mpv # Media player.
    kdenlive # Video editor.
  ];

  programs = {
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  # Enable Waydroid
  virtualisation.waydroid.enable = true;

  # List services that you want to enable:
  services = {
    # Enable Flatpack
    flatpak.enable = true;
    # Enable dbus
    dbus.enable = true;

    atuin = {
      enable = true;
      package = pkgs.atuin;
      openFirewall = true;
      port = 9090;
    };

    emacs = {
      enable = true;
      package = pkgs.emacs; # replace with emacs-gtk, or a version provided by the community overlay if desired.
    };

    # disable password auth for openssh
    openssh.settings.PasswordAuthentication = false;
  };

  # Enable virtualisation ( custom module )
  kvm.enable = true;

  # Open ports in the firewall.
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [80 443 22 465 9980 8090 6443];
      allowedUDPPorts = [67 68];
    };
    enableIPv6 = true;
    enableB43Firmware = true;
  };

  # Enable cron service
  # Note: *     *    *     *     *          command to run
  #      min  hour  day  month  year        user command
  # cron = {
  #  enable = true;
  #  systemCronJobs = [
  #    ''* * * * * akib     echo "Hello World" >> /home/akib/hello.txt''
  #  ];
  # };

  # Home manager configuration as a module
  home-manager = {
    useGlobalPkgs = false;
    users.${user} = {
      imports =
        map mkRelativeToRoot [
          "home-manager/home.nix" # config of home-manager
          "home-manager/${desktopEnvironment}/home.nix"
        ]
        ++ [(import ./home.nix)];
    };
    users."afif" = {
      imports =
        map mkRelativeToRoot [
          "home-manager/${desktopEnvironment}/home.nix"
        ]
        ++ [
          self.homeManagerModules.default # Custom home-manager modules
          ./home.nix
          {
            home = {
              # Home Manager needs a bit of information about you and the paths it should
              # manage.
              username = "afif";
              homeDirectory = "/home/afif";

              packages = with pkgs; [
                kitty # GPU-based terminal emulator.
                xdg-utils # Utilities for managing desktop integration.
                tree # Command-line directory tree viewer.
                hwinfo # Hardware information tool.
                ripgrep # Line-oriented search tool.

                # 2. Desktop Environment & Customization
                bibata-cursors # Cursor theme.
                adw-gtk3 # Adwaita theme for GTK 3.
              ];

              # This value determines the Home Manager release that your configuration is
              # compatible with. This helps avoid breakage when a new Home Manager release
              # introduces backwards incompatible changes.
              #
              # You should not change this value, even if you update Home Manager. If you do
              # want to update the value, then make sure to first check the Home Manager
              # release notes.
              stateVersion = "24.11"; # Please read the comment before changing.
            };
          }
        ];
    };
  };
}
