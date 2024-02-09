# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, unstable, user, state-version, ... }:

{
  #environment.shellInit = '' 
  #xrandr -s 1920x1080
  #wall=$(find /home/${user}/flake/public/wallpaper/ -type f -name "*.jpg" -o -name "*.png" | shuf -n 1)
  #xwallpaper --zoom $wall
  ##wal -c
  ##wal -i $wall
  ##xcompmgr &
  ##picom &
  #slstatus &
  #'';

  services.xserver.displayManager.sessionCommands = '' 
	xrandr -s 1920x1080
	wall=$(find /home/${user}/flake/public/wallpaper/ -type f -name "*.jpg" -o -name "*.png" | shuf -n 1)
	xwallpaper --zoom $wall
	wal -c
	wal -i $wall
	#xcompmgr &
	#picom &
	slstatus &
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # DWM setup
  services.xserver.windowManager.dwm.enable = true;
  # DWM overlay
  services.xserver.windowManager.dwm.package = pkgs.dwm.overrideAttrs {
    src = ./dwm;
  };

  environment.systemPackages = with pkgs; [
    firefox
    git
    htop
    gnumake
    neofetch
    pywal
    xwallpaper
    alacritty
    dmenu
    gcc
    nvim
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
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  services.picom.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "${state-version}"; # Did you read the comment?

}

