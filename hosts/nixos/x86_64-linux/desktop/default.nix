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
  theme,
  lib,
  inputs,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  imports = map mkRelativeToRoot [
    "home-manager/${desktopEnvironment}"
  ];

  # ---------------------------------------- Custom Nixos Modules ----------------------------------------------------
  nm = let
    secrets = fileName: builtins.toString inputs.secrets + fileName;
    readSecretsFile = fileName: lib.strings.trim (builtins.readFile (secrets fileName));
  in {
    # ------------------- Per-system user configuration -----------------------
    setUser = {
      # see modules/custom/nixos/user
      name = user;
      usersPath = ./users/.;
      nixosUsers.enable = true;
      homeUsers.enable = true;

      system = {
        inherit (system) name path;
        inherit desktopEnvironment state-version;
      };
    };

    # ------------------------ Enable Intel Gpu -------------------------------
    gpu = {
      enable = true;
      vendor = "intel";
      kernelParams = ["i915.force_probe=4680"];
    };

    # ---------------- kubernetes Container Orchestration ---------------------
    k8s = lib.mkIf (user == "akib") {
      enable = true;
      role = "master";
      defaultUser = user;
      kubeMasterIP = "192.168.0.111";
    };

    # ------------------- Docker Container Applications -----------------------
    docker = lib.mkIf (user == "akib") {
      enable = true;
      ipvlan.enable = true;
      iptables.enable = false;
      container = {
        n8n = {
          enable = true;
          defaultUser = user;
          dbPassword = readSecretsFile "/n8n/pass.txt";
          domain = readSecretsFile "/ngrok/domain.txt";
        };
        adguard.enable = true;
        jenkins.enable = true;
        portainer.enable = true;
        nextcloud = {
          enable = true;
          defaultUser = user;
          password = readSecretsFile "/nextcloud/pass.txt";
        };
      };
    };

    # ------------------------- Reverse Proxy Setting ------------------------------------
    ngnix = {
      enable = true;
      enableTLS = false; # Global setting for self-managed TLS
      routes = {
        "nextcloud.akibhome.lab" = {port = 8090;};
        "portainer.akibhome.lab" = {port = 9443;};
        "n8n.akibhome.lab" = {port = 5678;};
        "jenkins.akibhome.lab" = {port = 1010;};
        "adguard.akibhome.lab" = {
          target = "192.168.10.122";
          port = 80;
        };
      };
    };

    # ------------------------- Some Utils ------------------------------------
    ly.enable = true;
    kvm = {
      enable = true;
      bridge.enable = false;
    };
    gaming.enable = true;
    wireshark.enable = true;
    bbr.enable = true;
    fhs.enable = true;
    dbus.enable = true;
    obs.enable = true;
    openrazer.enable = true;

    # -------------------- Flatpak Application --------------------------------
    flatpak = {
      enable = true;
      apps = {
        enable = true;
        lists = [
          "sh.ppy.osu"
          "app.zen_browser.zen"
          "com.github.tchx84.Flatseal"
        ];
      };
    };

    # -------------------- Core Networking Configuration ----------------------
    networking = {
      enable = true;
      defaultGateway = {
        address = "192.168.0.1";
        interface = "enp4s0";
      };
      enableNetworkManager = false;
    };

    # -------------------- Samba Shares ---------------------------------------
    samba = {
      enable = true;
      # Define the drives you want to share
      shares = [
        {device = "sda1";}
        {device = "sda2";}
      ];
    };

    # ---------------------- RGB Stuff ----------------------------------------
    openrgb = {
      enable = true;
      motherboard = "intel"; # Explicitly set motherboard type
      # Pass your custom package here
      extraSystemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.toggleRGB
      ];
    };

    # ---------------------- System Wide Theme --------------------------------
    stylix = {
      enable = true;
      themeScheme = mkRelativeToRoot "public/themes/base16Scheme/${theme}.yaml";
    };

    # ---------------------- Ephemeral Storage  -------------------------------
    impermanence = {
      enable = true;
      inherit user; # REQUIRED: Set your primary username
      systemDirs = lib.mkIf (user == "akib") [
        # state for containers and orchestrators
        "/var/lib/docker"
        "/var/lib/kubernetes"
        "/var/lib/cfssl"
        "/var/lib/kubelet"
        "/var/lib/containerd"
        "/var/lib/etcd"
        # portainer docker & kubernetes management
        "/var/lib/portainer"
        #"/var/lib/pihole/"
        "/var/lib/adguardhome/work"
        "/var/lib/adguardhome/conf"
        "/var/lib/mariadb"
        "/var/lib/nextcloud/html"
        "/var/lib/nextcloud/data"
        "/var/lib/ngnixproxymanager"
        "/var/lib/letsencrypt"
        "/var/lib/postgresqln8n"
        "/var/lib/jenkins/"
        "/var/lib/ollama"
      ];
    };

    # ------------------- Atomic Secret Provisioning  -------------------------
    sops = lib.mkIf (user == "akib") {
      enable = true;
      defaultSopsFile = secrets "/secrets/secrets.yaml";
      secrets = {
        "akib/password/root_secret".neededForUsers = true;
        "akib/password/my_secret".neededForUsers = true;
        "akib/wireguard/PrivateKey".neededForUsers = true;
        "akib/cloudflared/token".neededForUsers = true;
        "afif/password/my_secret".neededForUsers = true;
      };
    };
  };

  # ---------------------------------------- System Stuff -----------------------------------------------------------------
  documentation.nixos.enable = true; # remove bloat
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
    wasistlos # WhatsApp client for Linux.

    # 4. Internet & Networking
    chromium # Web browser.
    qbittorrent # BitTorrent client.
    anydesk # Remote desktop software.
    remmina # Remote access screen
    localsend # Local file transfer tool.
    nextcloud-client # Nextcloud sync client.

    # 5. Productivity
    libreoffice # Office suite.
    figma-linux # Figma design tool.
    drawio # For creating diagrams
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
    jdk25 # Java Development Kit
    jetbrains.pycharm-community # Python IDE.
    jetbrains.idea-community # Java IDE.
    godot # Multi-platform 2D and 3D game engine
    postman # API development environment.
    vscode # Code editor.
    # zed-editor # Code editor.
    git # Version control system.
    # github-desktop # Git client.
    lazygit # Git UI.
    gh # GitHub CLI.
    # self.packages.${pkgs.stdenv.hostPlatform.system}.ciscoPacketTracer

    # 2. Media & Design
    gimp # Image editor.
    # krita # Digital painting software.
    # glaxnimate # Animation editor.
    # inkscape # Vector graphics editor.
    handbrake # Video transcoder.
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
}
