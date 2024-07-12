{
  config,
  pkgs,
  user ? "example.com",
  ...
}: {
  networking = {
    # Configure the default gateway for the network.
    defaultGateway = {
      address = "192.168.0.1"; # IP address of the default gateway.
      interface = "enp4s0"; # Network interface used to reach the default gateway.
    };

    # Define the DNS nameservers.
    nameservers = ["192.168.0.1"]; # List of DNS nameservers to use.

    # Set the domain name and search domain for the system.
    domain = "${user}"; # The domain name for the system, default is "example.com".
    search = ["${user}"]; # The search domain, used to resolve short hostnames.

    # Configure the network interfaces.
    interfaces = {
      # Configuration for the ethernet interface 'enp4s0'.
      enp4s0.ipv4.addresses = [
        {
          address = "192.168.0.111"; # Static IP address for the interface.
          prefixLength = 24; # Network prefix length (subnet mask).
        }
      ];

      # Configuration for the wireless interface 'wlp0s20f0u4'.
      wlp0s20f0u4.ipv4.addresses = [
        {
          address = "192.168.0.179"; # Static IP address for the interface.
          prefixLength = 24; # Network prefix length (subnet mask).
        }
      ];

      # Configuration for the virtual interface 'vlan2'.
      vlan2.ipv4.addresses = [
        {
          address = "192.168.2.1"; # Static IP address for the interface.
          prefixLength = 24; # Network prefix length (subnet mask).
        }
      ];
      vlan3.ipv4.addresses = [
        {
          address = "192.168.3.1"; # Static IP address for the interface.
          prefixLength = 24; # Network prefix length (subnet mask).
        }
      ];
    };

    # Configuration for VLAN interfaces.
    vlans = {
      # Configuration for VLAN with ID 2.
      vlan2 = {
        id = 2; # VLAN ID.
        interface = "enp4s0"; # Parent interface for the VLAN.
      };

      # Configuration for VLAN with ID 3.
      vlan3 = {
        id = 3; # VLAN ID.
        interface = "enp4s0"; # Parent interface for the VLAN.
      };
    };

    # Configuration for WireGuard interface using wg-quick. and protonvpn wireguard config file for the peer.
    wg-quick.interfaces = {
      # Define the WireGuard interface wg0.
      wg0 = {
        address = ["10.2.0.2/32"]; # IP address for the wg0 interface.
        dns = ["10.2.0.1"]; # DNS server for the wg0 interface.

        # Path to the private key file, managed by sops for secret management.
        privateKeyFile = config.sops.secrets."akib/wireguard/PrivateKey".path;

        # Configuration for the WireGuard peers.
        peers = [
          {
            publicKey = "URpeZxtyUXAUUA0MWcFdCSa7F+MvchJ4eNSJUetKEGk="; # Public key of the peer.
            allowedIPs = ["0.0.0.0/0"]; # IPs that are allowed to communicate through the peer.
            endpoint = "212.8.253.137:51820"; # Endpoint of the peer (IP address and port).
          }
        ];
      };
    };
  };
}
