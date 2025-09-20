{
  /*
  # General Instructions:
  # To access the server: http://192.168.10.121/admin/login
  # FIXME: To use the Pi-hole server, you need to set your router's DNS settings to the IP address of this Pi-hole server (192.168.10.121).
  # This will make Pi-hole your network's DNS server.

  # If you want to set a password for the Pi-hole web interface, run:
     $ docker exec -it pihole bash  # This command opens a shell into the running Pi-hole container
     $ sudo pihole -a -p            # This sets the admin password for the Pi-hole web interface

  # This command enables promiscuous mode on the Docker bridge network interface (docker0) to allow Pi-hole to monitor network traffic:
    $ sudo ip link set docker0 promisc on

  # List of blocklists to add to Pi-hole for ad-blocking: (optional)
    https://v.firebog.net/hosts/lists.php?type=tick

  # To update the blocklists in Pi-hole, run:
    $ docker exec -it pihole pihole -g  # This command updates the blocklists in Pi-hole
  # then restart the Pi-hole container to apply the changes.
  */

  # This enables Docker containers as systemd services in NixOS
  virtualisation.oci-containers = {
    # Docker is used as the backend for container management
    backend = "docker";

    # Defining the containers section
    containers = {
      # Pi-hole container configuration
      pihole = {
        # The Docker image for Pi-hole, latest version
        image = "pihole/pihole:latest";

        # Port mappings to allow external devices to access Pi-hole services ( currently don't needed as using ipvlan)
        ports = [
          # Forward DNS ports (53) on TCP and UDP to the host IP address (ServerIP)
          # "53:53/tcp" # DNS requests over TCP
          # "53:53/udp" # DNS requests over UDP
          # "67:67/udp" # Pi-hole as your DHCP Server
          # "443:443/tcp"

          # Forward HTTP (80) ports to Pi-hole for web access
          # "80:80" # Access Pi-hole's web interface on port 3080 instead of the default port 80
        ];

        # Volume mappings to persist Pi-hole data outside the container
        volumes = [
          # Persist Pi-hole configuration data
          "/var/lib/pihole:/etc/pihole"
        ];

        # Environment variables to configure the container
        environment = {
          TZ = "Asia/Dhaka";
          FTLCONF_dns_listeningMode = "all";
        };

        # Additional Docker options to give the container necessary permissions
        extraOptions = [
          # This adds network management capabilities to the container (required for DHCP or network operations)
          "--cap-add=NET_ADMIN"
          "--cap-add=SYS_TIME"
          "--cap-add=SYS_NICE"

          # Assign a static IP address to the container within the ipvlan network
          "--ip=192.168.10.121"
        ];

        /*
        * FIXME: create a network first :
        ```bash
          docker network create -d ipvlan \
              --subnet 192.168.10.0/24 -o parent=enp4s0 \
              -o ipvlan_mode=l3 --subnet 192.168.11.0/24 \
              level3
        ``

        * Make sure to create a routing table on your main router
          - Network Destination: 192.168.10.0 (your created subnet)
          - Subnet Mask: 255.255.255.0 (your assign subnet for the destination)
          - Default Gateway: (your desktop IP address, e.g., 192.168.0.111)
          - Interface: LAN (not WAN, because the route is internal)
        */
        networks = ["level3"];

        workdir = "/var/lib/pihole";
        autoStart = true;
      };
    };
  };
}
