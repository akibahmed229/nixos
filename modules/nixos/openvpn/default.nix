# modules/openvpn.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.openvpn;

  isServer = cfg.mode == "server";
  isClient = cfg.mode == "client";
in {
  # --- 1. Options (No changes needed) ---
  options.nm.openvpn = {
    # ... (this entire section is correct and requires no changes) ...
    enable = mkEnableOption "Enable OpenVPN configuration.";
    mode = mkOption {
      type = types.enum ["server" "client"];
      default = "server";
      description = "Specifies whether OpenVPN operates as a server or a client.";
    };
    client = {
      configFile = mkOption {
        type = types.path;
        description = "Path to the OpenVPN client configuration file (.ovpn).";
        example = "/path/to/my-vpn.ovpn";
      };
      serverName = mkOption {
        type = types.str;
        default = "vpn_client";
        description = "A name for this client VPN instance.";
      };
    };
    server = {
      serverName = mkOption {
        type = types.str;
        default = "vpn_server";
        description = "A name for this server instance.";
      };
      port = mkOption {
        type = types.int;
        default = 1194;
        description = "The port the OpenVPN server listens on.";
      };
      proto = mkOption {
        type = types.enum ["udp" "tcp"];
        default = "udp";
        description = "The protocol the OpenVPN server uses.";
      };
      serverNetwork = mkOption {
        type = types.str;
        description = "The virtual network for the VPN, including IP and subnet mask.";
        example = "10.8.0.0 255.255.255.0";
      };
      routesToPush = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of network routes to push to clients, allowing them to access local services.";
        example = ["192.168.0.0 255.255.255.0"];
      };
      dnsToPush = mkOption {
        type = types.listOf types.str;
        default = ["1.1.1.1" "1.0.0.1"];
        description = "List of DNS servers to push to clients.";
      };
      easy-rsa = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable and manage the certificate authority with easy-rsa.";
        };
        pkiDir = mkOption {
          type = types.path;
          default = "/var/lib/easy-rsa/pki";
          description = "Path to the Easy-RSA Public Key Infrastructure directory.";
        };
      };
      enableIpForward = mkOption {
        type = types.bool;
        default = true;
        description = "Enable IP forwarding (required for the server to act as a router).";
      };
      enableMasquerade = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NAT/Masquerading for traffic from VPN clients to the internet/LAN.";
      };
    };
  };

  /*
  # example usage:
    ```nix
      # openvpn
      openvpn = {
        enable = true;
        mode = "server";
        server = {
          # The virtual network for VPN clients
          serverNetwork = "10.8.0.0 255.255.255.0";

          # THIS IS THE KEY PART to expose your local services.
          # Replace with your actual local network range.
          routesToPush = ["192.168.0.0 255.255.255.0"];
        };
      };
    ```

  # Step 1: Generate the TLS-Auth Key
  #
  # On your server machine, navigate to your pki directory and use openvpn to generate the ta.key.
  # Bash
  #
  # # Become root user for these commands
  # sudo -i
  #
  # # Navigate to the correct directory
  # cd /var/lib/easy-rsa/pki
  #
  # # Generate the key
  # openvpn --genkey --secret ta.key
  #
  # # Log out of the root shell
  # exit
  #
  # You will now have a ta.key file inside /var/lib/easy-rsa/pki/.


  You've successfully generated the client certificate! That's great progress.

  You are seeing the WARNING: INCOMPLETE Inline file created because the easyrsa script is trying to be helpful by building an all-in-one .ovpn file, but it's missing one component it expects: a TLS Authentication key (ta.key).

  This key adds an extra layer of security and is highly recommended. The fix is to generate this key, tell your OpenVPN server to use it, and then re-generate the client configuration.

  On this fine Thursday morning here in Dhaka, let's get your VPN server properly hardened and your client configuration generated correctly.

  The Recommended Solution: Adding TLS-Auth

  This is the best practice. It will make your server more secure and resolve the easyrsa warning permanently.

  Step 1: Generate the TLS-Auth Key

  On your server machine, navigate to your pki directory and use openvpn to generate the ta.key.
  Bash

  # Become root user for these commands
  sudo -i

  # Navigate to the correct directory
  cd /var/lib/easy-rsa/pki

  # Generate the key
  openvpn --genkey --secret ta.key

  # Log out of the root shell
  exit

  You will now have a ta.key file inside /var/lib/easy-rsa/pki/.

  Step 2: Update Your openvpn.nix Module

  Now, we need to tell the OpenVPN server to use this new key. Add the tls-auth line to the config string in your modules/openvpn.nix.
  Nix

  # modules/openvpn.nix
  # ... inside the services.openvpn.servers."${cfg.server.serverName}".config string ...

  config = ''
    port ${toString cfg.server.port}
    proto ${cfg.server.proto}
    dev tun
    server ${cfg.server.serverNetwork}

    # Certificate and Key Files
    ca ${cfg.server.easy-rsa.pkiDir}/ca.crt
    cert ${cfg.server.easy-rsa.pkiDir}/issued/server.crt
    key ${cfg.server.easy-rsa.pkiDir}/private/server.key
    dh ${cfg.server.easy-rsa.pkiDir}/dh.pem

    # --- ADD THIS LINE ---
    # The '0' indicates this is the server. Clients will use '1'.
    tls-auth ${cfg.server.easy-rsa.pkiDir}/ta.key 0

    # Pushed settings to clients
    ${pushRoutes}
    ${pushDns}
    # ... rest of the config
  '';

  Step 3: Rebuild and Restart

  Apply the new server configuration and restart the service.
  Bash

  sudo nixos-rebuild switch
  sudo systemctl restart openvpn-vpn_server.service

  Step 4: Re-generate the Client Config

  Now that the server is configured and all the necessary keys exist, run the build-client-full command again. You can remove the old client files first for a clean state.
  Bash

  # Become root
  sudo -i

  # Navigate to the easy-rsa directory
  cd /var/lib/easy-rsa/

  # (Optional but recommended) Clean up the old client attempt
  ./easyrsa revoke client1
  # You may need to run `./easyrsa gen-crl` after revoking

  # Now, generate the complete config again
  ./easyrsa build-client-full client1 nopass

  This time, the command should complete without any warnings. It will find the ta.key and correctly generate a complete, all-in-one configuration file located at:

  /var/lib/easy-rsa/pki/inline/client1.ovpn

  This is the file you can directly import into your OpenVPN client application.
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [openvpn easyrsa];

    services.openvpn.servers = lib.mkMerge [
      # Server Configuration
      (lib.mkIf isServer {
        "${cfg.server.serverName}" = let
          pushRoutes = concatMapStringsSep "\n" (route: "push \"route ${route}\"") cfg.server.routesToPush;
          pushDns = concatMapStringsSep "\n" (dns: "push \"dhcp-option DNS ${dns}\"") cfg.server.dnsToPush;
        in {
          autoStart = true;
          config = ''
            port ${toString cfg.server.port}
            proto ${cfg.server.proto}
            dev tun

            # Certificate and Key Files
            server ${cfg.server.serverNetwork}
            ca ${cfg.server.easy-rsa.pkiDir}/pki/ca.crt
            cert ${cfg.server.easy-rsa.pkiDir}/pki/issued/server.crt
            key ${cfg.server.easy-rsa.pkiDir}/pki/private/server.key
            dh ${cfg.server.easy-rsa.pkiDir}/pki/dh.pem

            # The '0' indicates this is the server. Clients will use '1'.
            tls-auth ${cfg.server.easy-rsa.pkiDir}/pki/ta.key 0

            # Pushed settings to clients
            ${pushRoutes}
            ${pushDns}
            keepalive 10 120
            persist-key
            persist-tun
            status /var/log/openvpn-status.log
            verb 3
          '';
        };
      })

      # Client Configuration
      (lib.mkIf isClient {
        "${cfg.client.serverName}" = {
          autoStart = true;
          config = builtins.readFile cfg.client.configFile;
        };
      })
    ];

    # --- FIX #2: More robust firewall configuration ---
    # Open firewall ports for the server without overriding the whole firewall block.
    networking.firewall.allowedTCPPorts = mkIf (isServer && cfg.server.proto == "tcp") [cfg.server.port];
    networking.firewall.allowedUDPPorts = mkIf (isServer && cfg.server.proto == "udp") [cfg.server.port];

    # Enable IP Forwarding for the server
    boot.kernel.sysctl = mkIf (isServer && cfg.server.enableIpForward) (lib.mkDefault {"net.ipv4.ip_forward" = true;});

    # Enable NAT/Masquerade for the server
    networking.nat = mkIf (isServer && cfg.server.enableMasquerade) {
      enable = true;
      internalInterfaces = ["tun0"];
    };
  };
}
