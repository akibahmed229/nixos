# Configures the create_ap service for setting up a Wi-Fi access point.
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nm.createAp;
in {
  # --- 1. Define Options ---
  options.nm.createAp = {
    enable = mkEnableOption "Enable and configure the create_ap service (hostapd wrapper).";

    internetIface = mkOption {
      type = types.str;
      default = "";
      description = "The network interface connected to the internet (e.g., 'eth0', 'enp4s0').";
    };

    wifiIface = mkOption {
      type = types.str;
      default = "";
      description = "The Wi-Fi interface to create the access point on (e.g., 'wlan0', 'wlp0s20f0u4').";
    };

    ssid = mkOption {
      type = types.str;
      default = "";
      description = "The SSID (network name) for the access point.";
    };

    passphrase = mkOption {
      type = types.str;
      default = "";
      description = "The WPA2 passphrase for the access point (must be 8 characters or more).";
    };

    # Advanced feature: Allow free-form attribute set for other settings
    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "A free-form attribute set for additional create_ap settings (e.g., 'CHANNEL = 11').";
    };
  };
  /*
  # Example usage
  ```nix
    nm.createAp = {
      enable = true;

      # Core settings
      internetIface = "enp4s0";
      wifiIface = "wlp0s20f0u4";
      passphrase = "MySecurePassphrase123"; # Must be 8+ characters

      # Using the 'user' variable for a dynamic SSID, like your original config
      ssid = "${user}'s AP";

      # Extended feature: Add advanced options like forcing a channel
      extraSettings = {
        CHANNEL = 11;
        DAEMONIZE = true; # Run in background
      };
    };
  ```
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # --- Assertions (Improved Checks) ---
    assertions = [
      # Ensure both interfaces are defined
      {
        assertion = cfg.internetIface != "" && cfg.wifiIface != "";
        message = "When nm.createAp is enabled, 'internetIface' and 'wifiIface' must be set.";
      }
      # Ensure passphrase meets security minimum
      {
        assertion = builtins.stringLength cfg.passphrase >= 8;
        message = "The 'passphrase' must be at least 8 characters long for WPA2 security.";
      }
    ];

    services.create_ap = {
      enable = true;
      settings =
        {
          INTERNET_IFACE = cfg.internetIface;
          WIFI_IFACE = cfg.wifiIface;
          SSID = cfg.ssid;
          PASSPHRASE = cfg.passphrase;
        }
        // cfg.extraSettings; # Merge explicit settings with any extra user-defined attributes
    };
  };
}
