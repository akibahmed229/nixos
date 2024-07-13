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
    domain = "${user}";
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
          address = "192.168.0.179";
          prefixLength = 24;
        }
      ];

      # Configuration for the VLAN interfaces.
      vlan2.ipv4.addresses = [
        {
          address = "192.168.2.1";
          prefixLength = 24;
        }
      ];
      vlan3.ipv4.addresses = [
        {
          address = "192.168.3.1";
          prefixLength = 24;
        }
      ];
    };

    # Appending vlans to the network interfaces.
    vlans = {
      # Configuration for VLAN interfaces.
      vlan2 = {
        id = 2; # VLAN ID.
        interface = "enp4s0"; # Parent interface for the VLAN.
      };
      vlan3 = {
        id = 3;
        interface = "enp4s0";
      };
    };

    # Configuration for WireGuard interface using wg-quick. and protonvpn wireguard config file for the peer.
    wg-quick.interfaces = {
      # Define the WireGuard interface wg0.
      wg0 = {
        address = ["10.2.0.2/32"]; #
        dns = ["10.2.0.1"];

        # Path to the private key file, managed by sops for secret management.
        privateKeyFile = config.sops.secrets."akib/wireguard/PrivateKey".path;

        # Configuration for the WireGuard peers.
        peers = [
          {
            publicKey = "URpeZxtyUXAUUA0MWcFdCSa7F+MvchJ4eNSJUetKEGk=";
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "212.8.253.137:51820";
          }
        ];
      };
    };
  };
}
