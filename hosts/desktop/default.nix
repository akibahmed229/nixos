# default config files for desktop systems 

{ config
, pkgs
, user
, hostname
, devicename
, unstable
, inputs
, lib
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
      [ "sops" "stylix" "impermanence" "disko" "mysql" "postgresql" "gaming" ];

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
  documentation.nixos.enable = false;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    # List programs you want in your system Stable packages
    #cron
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
    obsidian
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
      nodejs_22
      nil
      jq
      rustc
      rustup
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
      postgresql
    ] else [ ]) ++ (
    if (hostname == "desktop" || hostname == "laptop") then
      with unstable.${pkgs.system};
      [
        git
        lazygit
        alacritty
        atuin
        telegram-desktop
        obs-studio
        #(pkgs.wrapOBS {
        #  plugins = with pkgs.obs-studio-plugins; [
        #    obs-teleport
        #    advanced-scene-switcher
        #    #self.packages.${pkgs.system}.obs-zoom-to-mouse
        #  ];
        #})
      ]
    else [ ]
  );

  # Eableing OpenGl support
  hardware.opengl = lib.mkIf (hostname == "desktop" || hostname == "laptop") {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with unstable.${pkgs.system}; [
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

  # Enable cron service
  # Note: *     *    *     *     *          command to run
  #      min  hour  day  month  year        user command
  # cron = {
  #  enable = true;
  #  systemCronJobs = [
  #    ''* * * * * akib     echo "Hello World" >> /home/akib/hello.txt''
  #  ];
  # };
}
