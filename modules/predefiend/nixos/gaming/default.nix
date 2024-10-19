{pkgs, ...}: {
  programs = {
    gamemode.enable = true; # set of tools to optimize system performance for games

    # Gamescope Compositor / "Boot to Steam Deck"
    gamescope = {
      enable = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
      package = pkgs.steam;
      # extraPackages = with pkgs.steamPackages; [
      # ];
      # remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      gamescopeSession.enable = true; # optimize micro compositor for games
    };
  };

  hardware.xone.enable = true; # support for the xbox controller USB dongle
  environment = {
    systemPackages = with pkgs; [
      protonup-qt
      mangohud
      bottles
      heroic
      (lutris.override {
        extraPkgs = pkgs: [
          # List package dependencies here
          wineWowPackages.stable
          winetricks
          # default icons
          pkgs.adwaita-icon-theme

          # MS fonts needed for KSP
          pkgs.corefonts
        ];

        extraLibraries = pkgs: [
          # libraries for Principia
          pkgs.llvmPackages.libcxx
          pkgs.llvmPackages.libunwind
        ];
      })
      # support both 32- and 64-bit applications
      wineWowPackages.stable
      # support 32-bit only
      wine
      # support 64-bit only
      (wine.override {wineBuild = "wine64";})
      # wine-staging (version with experimental features)
      wineWowPackages.staging
      # winetricks (all versions)
      winetricks
      # native wayland support (unstable)
      wineWowPackages.waylandFull
    ];
  };
}
