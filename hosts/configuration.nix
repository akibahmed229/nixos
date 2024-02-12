# common configuration for all machines.

{ config
, pkgs
, user
, hostname
, unstable
, nixpkgs
, lib
, ...
}:

{
  # Dual Booting using grub
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      theme = pkgs.sleek-grub-theme.override { withStyle = "dark"; withBanner = "Yo, sleek operator!"; };
      # splashImage = ../public/wallpaper/nixos.png;
      devices = [ "nodev" ]; # install grub on efi
      efiSupport = true;
      useOSProber = true; # To find Other boot manager like windows 
      configurationLimit = 5; # Store number of config 
    };

    timeout = 3; # Boot Timeout
  };

  # networking options
  networking.hostName = "${hostname}"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Dhaka";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

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


  # password can be hashed with: nix run nixpkgs#mkpasswd -- -m SHA-512 -s
  users.users.root.hashedPassword = "$6$V9VUyHMch1ZsocfS$zk5UFtOBFmIw/kc0mR9DIF03ooxkNHJLjDQbXbFO8lzN3spAWeszws4K1saheHEzIDxI6NNyr3xHyH.VQPHCs0";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    hashedPassword = "$6$y5qxEUAdhGfuMjTA$7zd9DbLF3hw8BCi.pOGI0BYg2hUTcNnP8FkzJtXfOgBOD9fv8cmBlmbMbiaOTsfeqeLyRgY/XMxkADpBsBa4Z0";
    description = "Akib Ahmed";
    extraGroups = [ "networkmanager" "wheel" "systemd-journal" "docker" "video" "audio" "scanner" "libvirtd" "kvm" "disk" "input" "plugdev" "adbusers" "flatpak" "plex" ];
    packages = with pkgs; [
      wget
      thunderbird
      vlc
    ];
  };
  security.sudo.wheelNeedsPassword = true; # User does not need to give password when using sudo.


  # Enable ADB for Android
  programs.adb.enable = true;

  programs.command-not-found.enable = false;
  programs.nix-index.enable = true;

  # environment variables Setting
  environment = {
    variables = {
      TERMINAL = "alacritty";
      EDITOR = "nvim";
      VISUAL = "nvim";
      #BROWSER = "firefox";
    };
  };

  # Font Setting
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      jetbrains-mono
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

  # XDG  paths
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # Not officially in the specification
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [
      "${XDG_BIN_HOME}"
    ];
  };

  # Adding Nix Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
