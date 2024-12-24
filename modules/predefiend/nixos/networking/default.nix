/*
* using nixos as a router: https://francis.begyn.be/blog/nixos-home-router
*/
{
  user ? "example.com",
  lib,
  config,
  ...
}: {
  networking = {
    # Configure the default gateway for the network.
    defaultGateway = {
      address = "192.168.0.1"; # IP address of the default gateway.
      interface = "enp4s0"; # Network interface used to reach the default gateway.
    };
    # Enable the NetworkManager service.
    networkmanager = {
      enable = lib.mkDefault true;
      wifi.macAddress = "random"; # option: random, stable, or a specific MAC address.
      ethernet.macAddress = "random";
    };

    # Define the DNS nameservers.
    nameservers = [
      # Public DNS Servers
      "1.1.1.1" # Cloudflare Primary
      "1.0.0.1" # Cloudflare Secondary
      "8.8.8.8" # Google Primary
      "8.8.4.4" # Google Secondary
      "94.140.14.14" # AdGuard Primary
      "94.140.15.15" # AdGuard Secondary
    ]; # List of DNS nameservers to use.

    # Set the domain name and search domain for the system.
    domain = "${user}";
    search = ["${user}"]; # The search domain, used to resolve short hostnames.

    # Configure the network interfaces.
    interfaces = {
      # Configuration for the ethernet interface 'enp4s0'.
      "Wired Connection 1" = {
        name = "enp4s0";
        ipv4.addresses = [
          {
            address = "192.168.0.111"; # Static IP address for the interface.
            prefixLength = 24; # Network prefix length (subnet mask).
          }
        ];
      };
      # Configuration for the wireless interface 'wlp0s20f0u4'.
      "Wireless Connection 1" = {
        name = "wlp0s20f0u4";
        ipv4.addresses = [
          {
            address = "192.168.0.179";
            prefixLength = 24;
          }
        ];
      };

      # Configuration for the VLAN interfaces.
      # vlan2.ipv4.addresses = [
      #   {
      #     address = "192.168.2.1";
      #     prefixLength = 24;
      #   }
      # ];
      # vlan3.ipv4.addresses = [
      #   {
      #     address = "192.168.3.1";
      #     prefixLength = 24;
      #   }
      # ];

      # Configuration for the WireGuard interface 'wg0'.
      # wg0.macAddress = "28:3A:4D:F2:0B:FE";
    };

    # Appending vlans to the network interfaces.
    # vlans = {
    #   # Configuration for VLAN interfaces.
    #   vlan2 = {
    #     id = 2; # VLAN ID.
    #     interface = "enp4s0"; # Parent interface for the VLAN.
    #   };
    #   vlan3 = {
    #     id = 3;
    #     interface = "enp4s0";
    #   };
    # };

    # Configuration for WireGuard interface using wg-quick. and protonvpn wireguard config file for the peer.
    # wg-quick.interfaces = lib.mkIf (config.sops.secrets."akib/wireguard/PrivateKey".path != {}) {
    #   # Define the WireGuard interface wg0.
    #   wg0 = {
    #     address = ["10.2.0.2/32"];
    #     dns = ["10.2.0.1"];

    #     # Path to the private key file, managed by sops for secret management.
    #     privateKeyFile = config.sops.secrets."akib/wireguard/PrivateKey".path;

    #     # Configuration for the WireGuard peers.
    #     peers = [
    #       {
    #         publicKey = "URpeZxtyUXAUUA0MWcFdCSa7F+MvchJ4eNSJUetKEGk=";
    #         allowedIPs = ["0.0.0.0/0"];
    #         endpoint = "212.8.253.137:51820";
    #       }
    #     ];
    #   };
    # };
  };
}
