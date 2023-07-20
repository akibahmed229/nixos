{ config, pkgs, user, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./desktop/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  #  boot.loader.systemd-boot.enable = true;
  #  boot.loader.efi.canTouchEfiVariables = true;

  # Dual Booting using grub
  boot.loader={
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      devices = ["nodev"]; # install grub
      efiSupport = true;
      useOSProber = true; # To find Other boot manager like windows 
      configurationLimit = 5; # Store number of config 
    };

    timeout = 5; # Boot Timeout
  };	
 

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

  # networking options
  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Dhaka";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #   useXkbConfig = true; # use xkbOptions in tty.
  };
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ typing-booster ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    # alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # wireplumber.enable = true;
  };


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Default Shell zsh
  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "Akib Ahmed";
    extraGroups = [ "ALL" "networkmanager" "network" "wheel" "systemd-journal" "docker" "video" "audio" "lb" "scanner" "libvirtd" "kvm" "disk" "input" ];
    packages = with pkgs; [
      wget
      thunderbird
      vlc
    ];
  };

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
    vscode	
    android-studio
    zip
    unzip
    p7zip
    ranger
    exa
    bat
    rtx
    distrobox
    cargo
    simplehttp2server
    speedtest-cli
    git
    gcc
    jdk
    python3Full
    nodejs_20
    yarn
    alacritty
    python310Packages.pip
    python310Packages.pyls-spyder
    flatpak
    appimage-run
    bottles
    spotify
    bleachbit
    obs-studio
    gimp
    libsForQt5.kdenlive
    inkscape
    brave
    handbrake
    audacity
    bottles
    gparted
    #libreoffice
    notepadqq 
    mangohud	
    goverlay
    anydesk
    geekbench
    qemu
    bridge-utils
    virt-manager
    #davinci-resolve
    ffmpeg_6
    gst_all_1.gstreamer
    openrgb-with-all-plugins
    openrgb-plugin-hardwaresync
    i2c-tools
    libverto
    fail2ban
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

    # Xdg-desktop-portal
    xdg-desktop-portal-gtk
    xorg.xkill
    xorg.libX11
    xorg.libX11.dev
    xorg.libxcb
    xorg.libXft
    xorg.libXinerama
    xorg.xinit
    # Gnome software 
    gnome.gnome-tweaks
    dconf
    # Gnome Extension
    gnomeExtensions.blur-my-shell
    #gnomeExtensions.burn-my-windows
    gnomeExtensions.caffeine
    gnomeExtensions.custom-hot-corners-extended
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.coverflow-alt-tab
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
    gnomeExtensions.user-avatar-in-quick-settings
    gnomeExtensions.gnome-40-ui-improvements
    gnomeExtensions.gsconnect
    #gnomeExtensions.impatience
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.tiling-assistant
    gnomeExtensions.vitals

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
	autosuggestions.enable = true;
	enableBashCompletion = true;
	syntaxHighlighting.enable = true;
	shellInit = ''
		source ../hosts/desktop/.zshrc
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

  # Font Setting
  fonts = {
   fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      source-han-sans
      (nerdfonts.override { fonts = [ "Meslo" ]; })
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
	      monospace = [ "Meslo LG M Regular Nerd Font Complete Mono" ];
	      serif = [ "Noto Serif" "Source Han Serif" ];
	      sansSerif = [ "Noto Sans" "Source Han Sans" ];
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
  # Enabling dfconf 
  programs.dconf.enable = true;
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
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
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


