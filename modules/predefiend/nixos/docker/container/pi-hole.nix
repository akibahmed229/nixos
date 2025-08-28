{
  /*
  # General Instructions:
  # To access the server: http://localhost:3080/admin/login.php
  # To use the Pi-hole server, you need to set your router's DNS settings to the IP address of this Pi-hole server (192.168.0.111).
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
  then restart the Pi-hole container to apply the changes.
  */

  # This enables Docker containers as systemd services in NixOS
  virtualisation.oci-containers = {
    # Docker is used as the backend for container management
    backend = "docker";

    # Defining the containers section
    containers = {
      # Pi-hole container configuration
      pihole = let
        # IP address of the Pi-hole server (static IP on your network)
        ServerIP = "192.168.0.111"; # Replace this with your Pi-hole server IP if it changes
      in {
        # The Docker image for Pi-hole, latest version
        image = "pihole/pihole:latest";

        # Port mappings to allow external devices to access Pi-hole services
        ports = [
          # Forward DNS ports (53) on TCP and UDP to the host IP address (ServerIP)
          "${ServerIP}:53:53/tcp" # DNS requests over TCP
          "${ServerIP}:53:53/udp" # DNS requests over UDP
          "${ServerIP}:67:67/udp" # Pi-hole as your DHCP Server
          "${ServerIP}:443:443/tcp"

          # Forward HTTP (80) ports to Pi-hole for web access
          "3080:80" # Access Pi-hole's web interface on port 3080 instead of the default port 80
        ];

        # Volume mappings to persist Pi-hole data outside the container
        volumes = [
          # Persist Pi-hole configuration data
          "/var/lib/pihole/:/etc/pihole/"
          # Persist DNS settings (dnsmasq configuration)
          "/var/lib/dnsmasq.d:/etc/dnsmasq.d/"
        ];

        # Environment variables to configure the container
        environment = {
          TZ = "Asia/Dhaka";
          FTLCONF_dns_listeningMode = "all";
          FTLCONF_misc_etc_dnsmasq_d = "true";
        };

        # Additional Docker options to give the container necessary permissions
        extraOptions = [
          "--cap-add=NET_ADMIN" # This adds network management capabilities to the container (required for DHCP or network operations)
          "--cap-add=SYS_TIME"
          "--cap-add=SYS_NICE"
          "--dns=127.0.0.1" # Set DNS resolver for the container to localhost (Pi-hole itself)
          "--dns=1.1.1.1" # Fallback DNS server to Cloudflare's DNS (1.1.1.1)
        ];

        # The working directory for the container
        workdir = "/var/lib/pihole/";

        # Automatically start the Pi-hole container when the system boots
        autoStart = true;
      };
    };
  };
}
