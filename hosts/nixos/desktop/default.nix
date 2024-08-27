/*
* Host-specific configuration for NixOS systems.
* This is your system's configuration file.
* Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
*/
{
  pkgs,
  user,
  hostname,
  desktopEnvironment,
  unstable,
  lib,
  self,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  imports =
    [(mkRelativeToRoot "home-manager/${desktopEnvironment}")]
    ++ mkImport {
      path = mkRelativeToRoot "modules/predefiend/nixos";
      ListOfPrograms = ["sops" "stylix" "impermanence" "mysql" "postgresql" "gaming" "networking" "bbr" "fhs"];
    };

  # Setting For OpenRGB
  services.hardware.openrgb = lib.mkIf (user == "akib" && hostname == "desktop") {
    enable = true;
    motherboard = "intel";
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      # self.overlays.discord-overlay
      # self.overlays.chromium-overlay
      # self.overlays.nvim-overlay

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
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
  environment.systemPackages =
    (with pkgs; [
      # List programs you want in your system Stable packages
      #cron
      htop
      trash-cli
      cava
      #espanso-wayland
      zip
      unzip
      p7zip
      ranger
      nvme-cli
      simplehttp2server
      speedtest-cli
      #onionshare
      flatpak
      appimage-run
      bleachbit
      gimp
      libsForQt5.kdenlive
      glaxnimate
      inkscape
      handbrake
      audacity
      gparted
      libreoffice
      qbittorrent
      figma-linux
      notepadqq
      gradience
      mangohud
      goverlay
      #anydesk
      geekbench
      kdiskmark
      chromium
      whatsapp-for-linux
      btop
      pipes
      #davinci-resolve
      ffmpeg_6
      gst_all_1.gstreamer
      openrgb-with-all-plugins
      openrgb-plugin-hardwaresync
      i2c-tools
      #polychromatic
      libverto
      fail2ban
      fzf
      tlrc
      obsidian
      # pppoe connection
      ppp
      rpPPPoE
      meson
      #gettext
      #rubyPackages.glib2
      libadwaita
      libinput
      cryptsetup
      veracrypt
    ])
    ++ (
      if user == "akib" && hostname == "desktop"
      then
        with unstable.${pkgs.system}; [
          # List unstable packages here
          jetbrains.pycharm-community
          jetbrains.idea-community
          postman
          vscode
          zed-editor
          android-tools
          android-udev-rules
          github-desktop
          android-studio
          gcc
          cmake
          gnumake
          libtool
          jdk21
          python312Full
          nodejs_22
          jq
          rustc
          rustup
          cargo
          direnv
          devbox
          distrobox
          busybox
          docker
          # self.packages.${pkgs.system}.docker-desktop
          docker-compose
          yarn
          mysql80
          mysql-workbench
          postgresql
          pgadmin4
        ]
      else []
    )
    ++ (
      if (hostname == "desktop" || hostname == "laptop")
      then
        with unstable.${pkgs.system}; [
          git
          fastfetch
          # solaar # Logitech Unifying Receiver
          localsend
          lazygit
          gh
          self.packages.${pkgs.system}.custom_nsxiv
          mpv
          atuin
          telegram-desktop
          darktable
          # obs-studio
          (pkgs.wrapOBS {
            plugins = with pkgs.obs-studio-plugins; [
              obs-teleport
              advanced-scene-switcher
              self.packages.${pkgs.system}.obs-zoom-to-mouse
            ];
          })
        ]
      else []
    );

  # Eableing OpenGl support
  hardware.opengl = lib.mkIf (hostname == "desktop" || hostname == "laptop") {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with unstable.${pkgs.system}; [
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      (vaapiIntel.override {enableHybridCodec = true;}) # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  programs = {
    wireshark = {
      enable = true;
      package = unstable.${pkgs.system}.wireshark;
    };
  };

  # List services that you want to enable:
  virtualisation = {
    # Enabling docker
    docker = {
      enable = true;
      storageDriver = "btrfs";
      #rootless = {
      #  enable = true;
      #  setSocketVariable = true;
      #};
    };
    # Enable WayDroid
    waydroid.enable = true;
  };
  services = {
    # Enable Flatpack
    flatpak.enable = true;
    # Enable dbus
    dbus.enable = true;

    atuin = {
      enable = true;
      openFirewall = true;
    };

    emacs = {
      enable = true;
      package = unstable.${pkgs.system}.emacs; # replace with emacs-gtk, or a version provided by the community overlay if desired.
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
      allowedTCPPorts = [80 443 22 465];
      allowedUDPPorts = [67 68];
      allowedUDPPortRanges = [
        {
          from = 4000;
          to = 4007;
        }
        {
          from = 8000;
          to = 8010;
        }
      ];
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
  };
}
