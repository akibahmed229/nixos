# default config files for desktop systems 

{ config
, pkgs
, user
, unstable
, inputs
, lib
, state-version
, ...
}:

{
  imports =
    # Include the results of the hardware scan.
    [ (import ./hardware-configuration.nix) ] ++
    [ (import ../../home-manager/hyprland/default.nix) ] ++ # uncomment to use Hyprland
    # [(import ../../home-manager/kde/default.nix)]; # uncomment to use KDE Plasma
    # [(import ../../home-manager/gnome/default.nix)]; # uncomment to Use GNOME
    # [(import ../../modules/predefiend/nixos/flatpak/flatpak.nix)]++
    [ (import ../../modules/predefiend/nixos/sops/sops.nix) ] ++
    [ (import ../../modules/predefiend/nixos/impermanence/impermanence.nix) ] ++
    [ (import ../../modules/predefiend/home-manager/tmux/tmux-service.nix) ];


  # Setting For OpenRGB
  services.hardware.openrgb = {
    enable = true;
    motherboard = "intel";
  };

  # Insecure permite
  nixpkgs.config.permittedInsecurePackages = [
    "python-2.7.18.6"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (builtins.parseDrvName pkg.name).name [
    "steam"
  ];


  # remove bloat
  #  documentation.nixos.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Default Shell zsh
  programs.zsh.enable = true;
  #programs.zsh.shellInit = ''
  #  source /home/${user}/flake/modules/predefiend/home-manager/zsh/zshrc
  #'';

  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];
  environment.pathsToLink = [ "/share/zsh" "/tmp" "/home/akib" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    # List programs you want in your system Stable packages
    neovim-unwrapped
    htop
    trash-cli
    cava
    neofetch
    vscode
    ripgrep
    android-tools
    android-udev-rules
    #espanso-wayland
    zip
    unzip
    p7zip
    ranger
    eza
    bat
    rtx
    nvme-cli
    distrobox
    cargo
    direnv
    devbox
    simplehttp2server
    speedtest-cli
    onionshare
    git
    gcc
    jdk21
    python312Full
    nodejs_21
    yarn
    docker-compose
    flatpak
    appimage-run
    bleachbit
    #obs-studio
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-teleport
        advanced-scene-switcher
        #(callPackage ../../pkgs/obs-studio-plugins/obs-zoom-to-mouse.nix { })
      ];
    })
    gimp
    libsForQt5.kdenlive
    glaxnimate
    inkscape
    handbrake
    audacity
    bottles
    gparted
    #libreoffice
    notepadqq
    gradience
    mangohud
    goverlay
    anydesk
    geekbench
    qemu
    bridge-utils
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    virtiofsd
    virglrenderer
    whatsapp-for-linux
    telegram-desktop
    btop
    #davinci-resolve
    ffmpeg_6
    gst_all_1.gstreamer
    openrgb-with-all-plugins
    openrgb-plugin-hardwaresync
    i2c-tools
    polychromatic
    libverto
    fail2ban
    fzf
    gamemode
    # bottles
    bottles
    # Heoric game luncher
    heroic-unwrapped
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
  ]) ++ (with unstable; [
    # List unstable packages here
    jetbrains.pycharm-community
    jetbrains.idea-community
    android-studio
    alacritty
    dwt1-shell-color-scripts
  ]);

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Eableing OpenGl support
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  hardware.opengl.driSupport32Bit = true;
  # Getting accelerated video playback
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:
  # Enabling docker  
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    #rootless = {
    #  enable = true;
    #  setSocketVariable = true;
    #};
  };
  # Enable WayDroid
  virtualisation.waydroid.enable = true;
  # Enable Flatpack
  services.flatpak.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 8080 ];
    settings = lib.mkDefault {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Enable virtualisation
  # <binary path="/run/current-system/sw/bin/virtiofsd"/> # virtiofsd binary path for virt-manager add this in virt-manager FileSystem Share
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
  # Enable dbus 
  services.dbus.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
      { from = 9000; to = 9010; } # Adding UDP port range 9000-9010 for illustration
    ];
  };
  networking.enableIPv6 = true;

  # Delete Garbage Collection previous generation collection
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # Enable Auto Update
  # system.copySystemConfiguration = true;
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-${state-version}";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "${state-version}"; # Did you read the comment?
}

