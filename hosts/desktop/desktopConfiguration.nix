{ config, pkgs, user, unstable, ... }:

{
  imports =
# Include the results of the hardware scan.
    [(import ./hardware-configuration.nix)] ++
    [(import ../../programs/flatpak/flatpak.nix)]++
# [(import ../../home-manager/kde/default.nix)]; # uncomment to use KDE Plasma
    [(import ../../home-manager/gnome/default.nix)]; # uncomment to Use GNOME


# Setting For OpenRGB
  services.hardware.openrgb = {
    enable = true;
    motherboard = "intel";
  };  

# Insecure permite
  nixpkgs.config.permittedInsecurePackages = [
    "python-2.7.18.6"
  ];

  nixpkgs.config.allowUnfreePredicate = (pkg: builtins.elem (builtins.parseDrvName pkg.name).name [ 
      "steam"
  ]);

# remove bloat
  documentation.nixos.enable = false;

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;
# List packages installed in system profile. To search, run:
# $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
      htop
      trash-cli
      bibata-cursors
      neofetch
      unstable.vscode	
      unstable.jetbrains.pycharm-community
      unstable.jetbrains.idea-community
      unstable.android-studio
      android-tools
      android-udev-rules
      zip
      unzip
      p7zip
      ranger
      exa
      bat
      rtx
      nvme-cli
      distrobox
      cargo
      direnv
      devbox
      simplehttp2server
      speedtest-cli
      git
      gcc
      jdk
      python311Full
      nodejs_20
      yarn
      unstable.alacritty
      python311Packages.pip
      python311Packages.virtualenv
      flatpak
      appimage-run
      spotify
      bleachbit
      obs-studio
      gimp
      libsForQt5.kdenlive
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
      whatsapp-for-linux
      btop
      discord
#davinci-resolve
      ffmpeg_6
      gst_all_1.gstreamer
      openrgb-with-all-plugins
      openrgb-plugin-hardwaresync
      i2c-tools
      libverto
      fail2ban
      fzf
      unstable.dwt1-shell-color-scripts
# bottles
      unstable.bottles
# Heoric game luncher
      unstable.heroic-unwrapped
# Steam
      unstable.steam
      unstable.steam-run
# luturis
      unstable.lutris
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
    gobject-introspection
    gnome.gdm
    meson
    gettext
    rubyPackages.glib2
    libadwaita
    polkit
    python310Packages.pygobject3
# xdg desktop portal    
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xorg.xkill
    xorg.libX11
    xorg.libX11.dev
    xorg.libxcb
    xorg.libXft
    xorg.libXinerama
    xorg.xinit
    ];

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
        vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
    ];
  };
  hardware.opengl.driSupport32Bit = true;

# Zsh and Oh-My-Zsh setup
  programs = {
    zsh = {
      enable = true;
      shellAliases = {la = "exa --icons -la  --group-directories-first";};
      autosuggestions.enable = true;
      enableBashCompletion = true;
      syntaxHighlighting.enable = true;
      shellInit = ''
        source /home/${user}/flake/programs/zsh/.zshrc
        '';
      syntaxHighlighting.highlighters = [
        "main" "brackets" "pattern" "cursor" "regexp" "root" "line"
      ];
      syntaxHighlighting.styles = { "alias" = "fg=magenta,bold"; };
      autosuggestions.highlightStyle = "fg=cyan";
      ohMyZsh = {
        enable = true;
        plugins = [
          "git"
            "sudo"
            "terraform"
            "systemadmin"
            "vi-mode"
        ];
        theme = "agnoster";
      };
    };
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
  virtualisation.docker.enable = true;	
# Enable Flatpack
  services.flatpak.enable = true;
# Enable the OpenSSH daemon.
  services.openssh.enable = true;
# Enable virtualisation
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf.enable = true;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
# Enable dbus 
  services.dbus.enable = true; 

# Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22];
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
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-23.05";

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It's perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

# Adding Nix Flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

}

