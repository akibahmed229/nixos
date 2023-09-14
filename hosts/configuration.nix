{ config, pkgs, user, unstable, nixpkgs, ... }:

{
  imports = 
    [(import ./desktop/desktopConfiguration.nix)];
    #[(import ../shells/python.nix)];
    

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

# networking options
  networking.hostName = "Ahmed"; # Define your hostname.
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

# Default Shell zsh
  users.defaultUserShell = pkgs.zsh;

# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "Akib Ahmed";
    extraGroups = [ "networkmanager" "network" "wheel" "systemd-journal" "docker" "video" "audio" "lb" "scanner" "libvirtd" "kvm" "disk" "input" "plugdev" "adbusers" "flatpak" ];
    packages = with pkgs; [
      wget
        thunderbird
        vlc
        brave
    ];
  };
  security.sudo.wheelNeedsPassword = false; # User does not need to give password when using sudo.


# Enable ADB for Android
  programs.adb.enable = true;

# environment variables Setting
  environment = {
    variables = {
      TERMINAL = "alacritty";
      EDITOR = "nvim";
      VISUAL = "nvim";
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
}
