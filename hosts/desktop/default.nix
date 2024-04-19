# default config files for desktop systems 

{ config
, pkgs
, user
, hostname
, devicename
, unstable
, inputs
, lib
, state-version
, self
, ...
}:

{
  imports =
    # Include the results of the hardware scan.
    [ (import ./hardware-configuration.nix) ] ++
    [ (import ../../home-manager/hyprland/default.nix) ] ++ # uncomment to use Hyprland
    # [(import ../../home-manager/kde/default.nix)]; # uncomment to use KDE Plasma
    # [(import ../../home-manager/gnome/default.nix)]; # uncomment to Use GNOME
    map
      (myprograms:
        let
          path = name:
            if name == "disko" then
              (import ../../modules/predefiend/nixos/${name} { device = "${devicename}"; }) # diskos module with device name (e.g., /dev/sda1)
            else
              (import ../../modules/predefiend/nixos/${name}); # path to the module
        in
        path myprograms # loop through the myprograms and import the module
      )
      # list of programs
      [ "sops" "impermanence" "tmux" "disko" "mysql" ];

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

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;

      # Insecure permite
      permittedInsecurePackages = [
        "python-2.7.18.6"
        "electron-25.9.0"
      ];
      allowUnfreePredicate = pkg: builtins.elem (builtins.parseDrvName pkg.name).name [
        "steam"
      ];
    };
  };

  # remove bloat
  # documentation.nixos.enable = false;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    # List programs you want in your system Stable packages
    neovim-unwrapped
    htop
    trash-cli
    cava
    neofetch
    #espanso-wayland
    zip
    unzip
    p7zip
    ranger
    eza
    bat
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
    bottles
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
    gamemode
    # bottles
    bottles
    obsidian
    # Heoric game luncher
    heroic
    # Steam
    steam
    steam-run
    # luturis
    lutris
    (lutris.override {
      extraPkgs = pkgs: [
        # List package dependencies here
        wineWowPackages.stable
        winetricks
      ];
    })
    # support both 32- and 64-bit applications
    wineWowPackages.stable
    # support 32-bit only
    wine
    # support 64-bit only
    (wine.override { wineBuild = "wine64"; })
    # wine-staging (version with experimental features)
    wineWowPackages.staging
    # winetricks (all versions)
    winetricks
    # native wayland support (unstable)
    wineWowPackages.waylandFull
    # pppoe connection
    ppp
    rpPPPoE
    # Login manager customizetion for gdm
    #gobject-introspection
    meson
    #gettext
    #rubyPackages.glib2
    libadwaita
    polkit
    #python310Packages.pygobject3
  ]) ++ (if user == "akib" && hostname == "desktop" then
    with unstable.${pkgs.system};
    [
      # List unstable packages here
      jetbrains.pycharm-community
      jetbrains.idea-community
      postman
      vscode
      android-tools
      android-udev-rules
      github-desktop
      android-studio
      dwt1-shell-color-scripts
      gcc
      jdk21
      python312Full
      nodejs_21
      jq
      rustc
      cargo
      direnv
      devbox
      distrobox
      docker
      # self.packages.${pkgs.system}.docker-desktop
      docker-compose
      yarn
      mysql-workbench
      mysql80
    ] else [ ]) ++ (
    if (hostname == "desktop" || hostname == "laptop") then
      with unstable.${pkgs.system};
      [
        git
        lazygit
        alacritty
        atuin
        telegram-desktop
        #obs-studio
        (pkgs.wrapOBS {
          plugins = with pkgs.obs-studio-plugins; [
            obs-teleport
            advanced-scene-switcher
            self.packages.${pkgs.system}.obs-zoom-to-mouse
          ];
        })
      ]
    else [ ]
  );

  # Gaming
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Eableing OpenGl support
  hardware.opengl = lib.mkIf (hostname == "desktop" || hostname == "laptop") {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      (vaapiIntel.override { enableHybridCodec = true; }) # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
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
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      ports = [ 8080 ];
      settings = lib.mkDefault {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    # Enable dbus 
    dbus.enable = true;
    atuin = {
      enable = true;
      openFirewall = true;
    };
  };

  # Enable virtualisation ( custom module )
  kvm.enable = true;

  # Open ports in the firewall.
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 22 ];
      allowedUDPPortRanges = [
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
        { from = 9000; to = 9010; } # Adding UDP port range 9000-9010 for illustration
      ];
    };
    enableIPv6 = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # Enable Auto Update
  # system.copySystemConfiguration = true;
  system = {
    autoUpgrade.enable = true;
    autoUpgrade.channel = "https://nixos.org/channels/nixos-${state-version}";

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "${state-version}"; # Did you read the comment?
  };
}
