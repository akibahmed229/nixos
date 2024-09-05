{_, ...}: {
  /*
  # You need to add IP-Address of the setup pi-hole server to your router's DNS settings or DHCP settings to use the pi-hole as the DNS server.

  # To setup pi-hole password, run the following command:
     $ docker exec -it pihole bash
     $ sudo pihole -a -p
  */
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      pihole = let
        ServerIP = "192.168.0.111";
      in {
        image = "pihole/pihole:latest";
        ports = [
          "${ServerIP}:53:53/tcp"
          "${ServerIP}:53:53/udp"
          "3080:80"
          "30443:443"
        ];
        volumes = [
          "/var/lib/pihole/:/etc/pihole/"
          "/var/lib/dnsmasq.d:/etc/dnsmasq.d/"
        ];
        environment = {
          ServerIP = "${ServerIP}";
          TZ = "Asia/Dhaka";
        };
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--dns=127.0.0.1"
          "--dns=1.1.1.1"
        ];
        workdir = "/var/lib/pihole/";
        autoStart = true;
      };
    };
  };
}
