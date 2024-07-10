{
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

    # Configuration for the VLAN interface
    vlans = {
      # Configuration for the VLAN interface
      vlan2 = {
        id = 2; # VLAN ID.
        interface = "enp4s0"; # Parent interface for the VLAN.
      };
      vlan3 = {
        id = 3; # VLAN ID.
        interface = "enp4s0"; # Parent interface for the VLAN.
      };
    };
  };
}
