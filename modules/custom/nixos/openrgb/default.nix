# modules/openrgb.nix
# Configures OpenRGB for hardware lighting control, including necessary kernel modules and udev rules.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.openrgb;
in {
  # --- 1. Define Options ---
  options.nm.openrgb = {
    enable = mkEnableOption "Enable OpenRGB hardware lighting control and server.";

    motherboard = mkOption {
      type = types.str;
      default = "intel";
      description = "The motherboard driver to use for OpenRGB (e.g., 'intel' or 'asus').";
    };

    serverPort = mkOption {
      type = types.int;
      default = 9999;
      description = "The network port for the OpenRGB SDK server.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.openrgb-with-all-plugins;
      description = "The OpenRGB package to use, typically with all plugins.";
    };

    extraSystemPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra packages to install system-wide, often includes custom tools like 'toggleRGB'.";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # Essential kernel modules for hardware communication
    boot.kernelModules = ["i2c-dev"];
    hardware.i2c.enable = true;

    # Udev rules are needed so OpenRGB can access hardware without root
    services.udev.packages = [pkgs.openrgb];

    # Configure the OpenRGB service
    services.hardware.openrgb = {
      enable = true;
      package = cfg.package;
      motherboard = cfg.motherboard;
      server.port = cfg.serverPort;
    };

    # Install the extra system packages (like the toggle script)
    environment.systemPackages = cfg.extraSystemPackages;
  };
}
