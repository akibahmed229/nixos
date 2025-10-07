# Configures WireGuard to run in either server or client mode,
# including all necessary firewall, kernel, and dynamic DNS settings.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.wireguard;

  isServer = cfg.mode == "server";
  isClient = cfg.mode == "client";
in {
  # --- 1. Define Options ---
  options.nm.wireguard = {
    enable = mkEnableOption "Enable WireGuard VPN configuration.";

    mode = mkOption {
      type = types.enum ["server" "client"];
      default = "server";
      description = "Specifies whether WireGuard operates as a server or a client.";
    };

    interfaceName = mkOption {
      type = types.str;
      default = "wg0";
      description = "The name of the WireGuard interface (e.g., 'wg0').";
    };

    address = mkOption {
      type = types.listOf types.str;
      description = "IP address(es) and CIDR mask for the WireGuard interface.";
      example = ["10.10.10.1/24"];
    };

    privateKeyFile = mkOption {
      type = types.path;
      description = "Path to the WireGuard private key file (e.g., /var/lib/wireguard/private.key).";
    };

    # Client-specific options
    client = {
      dns = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "DNS servers to use when in client mode.";
      };
      peer = mkOption {
        type = types.attrsOf types.unspecified;
        default = {};
        description = "Configuration for the single VPN peer (publicKey, allowedIPs, endpoint).";
        example = {
          publicKey = "...";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "vpn.example.com:51820";
        };
      };
    };

    # Server-specific options
    server = {
      listenPort = mkOption {
        type = types.int;
        default = 51820;
        description = "The UDP port the WireGuard server listens on.";
      };
      peers = mkOption {
        type = types.listOf (types.attrsOf types.unspecified);
        default = [];
        description = "List of client peer configurations for the server.";
      };
      enableIpForward = mkOption {
        type = types.bool;
        default = true;
        description = "Enable IP forwarding (required for the server to act as a router).";
      };
      enableMasquerade = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NAT/Masquerading for traffic leaving the WireGuard interface onto the public interface.";
      };

      # DuckDNS Options
      duckdns = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable automatic IP update for DuckDNS.";
        };
        domain = mkOption {
          type = types.str;
          description = "The DuckDNS domain name to update.";
        };
        token = mkOption {
          type = types.str;
          description = "The DuckDNS token/UUID for authentication.";
        };
      };
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 Base Utilities and Dependencies
    environment.systemPackages = with pkgs; [
      wireguard-tools
      qrencode
      iptables
      curl # Needed for DuckDNS/Dynamic DNS updates
    ];

    # 2.2 Firewall Configuration
    networking.firewall = {
      # Allow the listen port if in server mode
      allowedUDPPorts = lib.optionals isServer [cfg.server.listenPort];
      # Trust the WireGuard interface itself
      trustedInterfaces = [cfg.interfaceName];
    };

    # 2.3 IP Forwarding (Required for Server Mode)
    boot.kernel.sysctl = mkIf (isServer && cfg.server.enableIpForward) (lib.mkDefault {
      "net.ipv4.ip_forward" = true;
    });

    # 2.4 NAT/Masquerade (Required for Server Mode to route internet traffic)
    networking.nat = mkIf (isServer && cfg.server.enableMasquerade) {
      enable = true;
      internalInterfaces = [cfg.interfaceName];
    };

    # 2.5 WireGuard Interface Configuration
    networking.wg-quick.interfaces = {
      "${cfg.interfaceName}" = lib.mkMerge [
        {
          address = cfg.address;
          privateKeyFile = cfg.privateKeyFile;
        }
        (lib.mkIf isServer {
          # Server-specific settings
          listenPort = mkIf isServer cfg.server.listenPort;
          peers = mkIf isServer cfg.server.peers;
        })
        (lib.mkIf isClient {
          # Client-specific settings
          dns = mkIf isClient cfg.client.dns;
          # In client mode, we expect a single peer (the VPN endpoint)
          peers = mkIf isClient [cfg.client.peer];
        })
      ];
    };

    # 2.6 DuckDNS Service (Server-specific Feature)
    systemd.services.duckdns = mkIf (isServer && cfg.server.duckdns.enable) {
      description = "Update DuckDNS IP";
      serviceConfig.ExecStart = ''
        ${pkgs.curl}/bin/curl "https://www.duckdns.org/update?domains=${cfg.server.duckdns.domain}&token=${cfg.server.duckdns.token}&ip="
      '';
    };

    systemd.timers.duckdns = mkIf (isServer && cfg.server.duckdns.enable) {
      description = "Run DuckDNS update every 5 minutes";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "5m";
      };
    };
  };
}
/*
#### Example 1: WireGuard Server Configuration
```nix
  nm.wireguard = {
    enable = true;
    mode = "server"; # Set mode to server

    interfaceName = "wg0";
    address = ["10.10.10.1/24"];
    privateKeyFile = "/var/lib/wireguard/server_private.key"; # Must exist and be secure!

    server = {
      listenPort = 51820;

      # Enable DuckDNS (replace domain and token with yours)
      duckdns.enable = true;
      duckdns.domain = "your_duckduck_sub_domain";
      duckdns.token = "your_token";

      # Define clients/peers
      peers = [
        {
          # Client 1 Public Key
          publicKey = "8lulMQreiz2H5i/MxkzEU7fGbbpt1Lqt1atZdlCgJkk=";
          allowedIPs = ["10.10.10.2/32"];
        }
      ];
    };
```

#### Example 2: WireGuard **Client** Configuration (e.g., connecting to a commercial VPN)

```nix
{
  nm.wireguard = {
    enable = true;
    mode = "client"; # Set mode to client

    interfaceName = "wg0";
    address = ["10.2.0.2/32"];
    privateKeyFile = '/var/lib/wireguard/server_private.key; # Use secret path

    client = {
      dns = ["10.2.0.1"]; # VPN's internal DNS

      # Define the remote VPN endpoint peer
      peer = {
        publicKey = "URpeZxtyUXAUUA0MWcFdCSa7F+MvchJ4eNSJUetKEGk=";
        allowedIPs = ["0.0.0.0/0"]; # Route all traffic through the VPN
        endpoint = "212.8.253.137:51820";
      };
    };
  };
*/
/*
The Step-by-Step Guid to generate server and client key

Let's generate two distinct key pairs and put them in the correct places.

1. Generate a SERVER Key Pair

Run these commands on your NixOS machine. This will create and secure a dedicated key pair for the server.
Bash

```bash
    # Create the server's private and public keys
    wg genkey | sudo tee /var/lib/wireguard/server_private.key | wg pubkey | sudo tee /var/lib/wireguard/server_public.key

    # Set correct permissions for the private key
    sudo chmod 600 /var/lib/wireguard/server_private.key
```

2. Generate a CLIENT Key Pair

Run this in your home directory. This key pair is exclusively for your phone.
Bash

```bash
    # Create the client's private and public keys
    wg genkey | tee client_private.key | wg pubkey > client_public.key
```

3. Configure the SERVER (default.nix)

Now, update your NixOS configuration with the correct keys.

    Get the client's public key: cat ~/client_public.key


```nix
    # In your NixOS configuration
    networking.wg-quick.interfaces.wg0 = {
      address = ["10.10.10.1/24"];
      listenPort = 51820;
      # Use the new server private key
      privateKeyFile = "/var/lib/wireguard/server_private.key";

      peers = [
        {
          # Use the CLIENT'S public key here
          publicKey = "<PASTE THE CLIENT'S PUBLIC KEY FROM client_public.key>";
          allowedIPs = ["10.10.10.2/32"];
        }
      ];
    };
```

4. Configure the CLIENT (Phone)

Update your phone's configuration with its private key and the server's public key.

    Get the client's private key: cat ~/client_private.key

    Get the server's public key: sudo cat /var/lib/wireguard/server_public.key


```Ini, TOML
    # On your phone
    [Interface]
    PrivateKey = <PASTE THE CLIENT'S PRIVATE KEY FROM client_private.key>
    Address = 10.10.10.2/32
    DNS = 1.1.1.1

    [Peer]
    PublicKey = <PASTE THE SERVER'S PUBLIC KEY FROM server_public.key>
    Endpoint = akiblab.duckdns.org:51820
    AllowedIPs = 10.10.10.0/24, 192.168.1.0/24
    PersistentKeepalive = 25
```
*/

