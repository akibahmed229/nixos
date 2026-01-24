# Configures the Point-to-Point Protocol Daemon (pppd) for PPPoE connections.
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nm.pppd;

  # Define the structure for a single PPPoE peer connection
  peerType = types.submodule {
    options = {
      enable = mkEnableOption "Enable this specific PPPoE peer configuration.";

      autostart = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to automatically start the PPPoE session on boot.";
      };

      interface = mkOption {
        type = types.str;
        default = "wan";
        description = "The physical interface to use for the PPPoE connection (e.g., 'eth0' or 'wan').";
      };

      username = mkOption {
        type = types.str;
        default = "random";
        description = "The username to use for the PPPoE authentication ('name' option in pppd config).";
      };

      password = mkOption {
        type = types.str;
        default = "random";
        description = "The password to use for the PPPoE authentication.";
      };

      configExtra = mkOption {
        type = types.lines;
        default = ''
          persist
          maxfail 0
          holdoff 5

          noipdefault
          defaultroute
        '';
        description = "Extra configuration lines to append to the pppd configuration file.";
      };
    };
  };
in {
  # --- 1. Define Options ---
  options.nm.pppd = {
    enable = mkEnableOption "Enable and configure the pppd network service.";

    peers = mkOption {
      type = types.attrsOf peerType;
      default = {};
      example = literalExample ''
        edpnet = {
          username = "user@isp.net";
          password = "super-secret-password";
          interface = "eth0";
        };
      '';
      description = "An attribute set of PPPoE peer configurations.";
    };
  };

  /*
  * When the system starts up pppd-edpnet.service, you should now see a ppp0 interface
    with an IP address (note: if you already have a default gateway set on the system
    when the PPPoE seesion comes online, it will not replace the degault gateway).

  # Example usage
  ```nix
   nm.pppd = {
    enable = true;

    peers = {
      # This peer replicates your original 'edpnet' configuration
      edpnet = {
        enable = true;
        username = "your_actual_username"; # Update this
        password = "your_actual_password"; # Update this
        interface = "enp4s0";

        # All default configExtra lines are used unless you explicitly override them
      };

      # Example of a second, more minimalist peer
      test_session = {
        enable = false; # Disabled by default
        autostart = false;
        username = "testuser";
        password = "testpassword";
        interface = "eth1";
        configExtra = ''
          defaultroute
        '';
      };
    };
  };
  ````
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # Main pppd service enablement
    services.pppd.enable = true;

    # Map the modular peers configuration to the upstream service.pppd.peers structure
    services.pppd.peers =
      mapAttrs
      (name: peer: {
        # Pass through the standard options
        enable = peer.enable;
        autostart = peer.autostart;

        # Construct the final pppd configuration file content
        config = ''
          plugin rp-pppoe.so ${peer.interface}

          name "${peer.username}"
          password "${peer.password}"

          ${peer.configExtra}
        '';
      })
      # Only process peers that are explicitly enabled
      (filterAttrs (name: peer: peer.enable) cfg.peers);
  };
}
