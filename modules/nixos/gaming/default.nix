# modules/gaming.nix
# Configures a comprehensive gaming environment including Steam, Gamescope,
# various Wine packages, and system performance optimizations (gamemode, mangohud).
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.gaming;

  # Define common dependencies for the extended Lutris setup
  lutrisExtraPkgs = with pkgs; [
    wineWowPackages.stable
    winetricks
    adwaita-icon-theme # default icons
    corefonts # MS fonts needed for some Windows applications (e.g., KSP)
  ];

  lutrisExtraLibs = with pkgs; [
    llvmPackages.libcxx # libraries for Principia/other specific software
    llvmPackages.libunwind
  ];
in {
  # --- 1. Define Options ---
  options.nm.gaming = {
    enable = mkEnableOption "Enable core gaming environment (Steam, Gamescope, Wine, Gamemode)";

    enableMangohud = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Mangohud (overlay for FPS, temperature, etc.).";
    };

    enableDedicatedServerFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall ports for Steam Dedicated Server (Source Engine).";
    };

    # Note: Xone controller support is commented out in the original and omitted here,
    # but can be added back if it becomes stable: hardware.xone.enable
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 System Optimization
    programs.gamemode.enable = true;

    # 2.2 Gamescope (Optimized Compositor) / "Boot to Steam Deck"
    programs.gamescope = {
      enable = true;
      capSysNice = true; # Allow Gamescope to adjust scheduling priority
    };

    # 2.3 Steam Client Configuration
    programs.steam = {
      enable = true;
      package = pkgs.steam;
      dedicatedServer.openFirewall = cfg.enableDedicatedServerFirewall;
      gamescopeSession.enable = true;
    };

    # 2.4 Gaming Utilities and Wine Environments
    environment.systemPackages = with pkgs;
      [
        protonup-qt
        bottles
        heroic
        wineWowPackages.stable # support both 32- and 64-bit applications
        wine # support 32-bit only
        (wine.override {wineBuild = "wine64";}) # support 64-bit only
        wineWowPackages.staging # wine-staging (version with experimental features)
        winetricks
        wineWowPackages.waylandFull # native wayland support (unstable)

        # 2.5 Lutris with extra packages
        (lutris.override {
          extraPkgs = _: lutrisExtraPkgs;
          extraLibraries = _: lutrisExtraLibs;
        })
      ]
      # Include Mangohud if enabled via option
      ++ (lib.optionals cfg.enableMangohud [pkgs.mangohud]);
  };
}
