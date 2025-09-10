# DWM system configuration
{
  self,
  pkgs,
  user,
  ...
}: {
  services = {
    # Enable the X11 windowing system.
    xserver.enable = true;
    # DWM setup
    xserver = {
      displayManager.sessionCommands = ''
        xrandr -s 1920x1080
        wall=$(find /home/${user}/.config/flake/public/wallpapers/ -type f -name "*.jpg" -o -name "*.png" | shuf -n 1)
        xwallpaper --zoom $wall
        wal -c
        wal -i $wall
        #xcompmgr &
        #picom &
        slstatus &
      '';
      windowManager.dwm.enable = true;
      # DWM overlay
      windowManager.dwm.package = pkgs.dwm.overrideAttrs {
        src = ./dwm;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    htop
    gnumake
    neofetch
    pywal
    xwallpaper
    gcc
    neovim
    xcompmgr
    kdePackages.ark
    eog
    networkmanagerapplet
    # rPackages.pkgmaker # FIXME: currently broken
    xorg.xrandr
    xorg.xinit
    xorg.makedepend
    xorg.libX11
    xorg.libX11.dev
    xorg.libxcb
    xorg.libXft
    xorg.xkill
    xorg.libXinerama
    xorg.xrdb
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    mtr.enable = true;
    dconf.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # List services that you want to enable:

  services = {
    picom.enable = true;
    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.gnome.gnome-keyring.enable = true;

  # polkit for authentication ( from custom nixos module )
  myPolkit.enable = true;
}
