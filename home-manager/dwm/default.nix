# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  config,
  pkgs,
  unstable,
  user,
  state-version,
  ...
}: {
  services = {
    # Enable the X11 windowing system.
    xserver.enable = true;
    # DWM setup
    xserver = {
      displayManager.sessionCommands = ''
        xrandr -s 1920x1080
        wall=$(find /home/${user}/.config/flake/public/wallpaper/ -type f -name "*.jpg" -o -name "*.png" | shuf -n 1)
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
    firefox
    git
    htop
    gnumake
    neofetch
    pywal
    xwallpaper
    dmenu
    gcc
    neovim
    xcompmgr
    rPackages.pkgmaker
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
    picom
    (st.overrideAttrs {
      src = ./st;
    })
    (slstatus.overrideAttrs {
      src = ./slstatus;
    })
    (dmenu.overrideAttrs {
      src = ./dmenu;
    })
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
}
