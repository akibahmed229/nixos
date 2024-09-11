{
  /*
  * Nginx Proxy Manager
  * Nginx Proxy Manager allows you to forward HTTP/HTTPS traffic to services in your network.
    It is a reverse proxy that sits in front of your services and forwards client requests to the appropriate backend server.
    it also server static files and can be used as a load balancer.

  * Default email: admin@example.com
  * Default password: changeme
  */
  # This enables Docker containers as systemd services in NixOS
  virtualisation.oci-containers = {
    # Docker is used as the backend for container management
    backend = "docker";

    # Defining the containers section
    containers = {
      ngnixproxymanager = {
        image = "jc21/nginx-proxy-manager:latest";

        # Port mappings to allow external devices to access ngnixproxymanager web interface
        ports = [
          # These ports are in format <host-port>:<container-port>
          "80:80" # Public HTTP Port
          "443:443" # Public HTTPS Port
          "8111:81" # Admin Web Port
          # Add any other Stream port you want to expose
          # - '21:21' # FTP
        ];

        # Volume mappings to persist ngnixproxymanager data outside the container
        volumes = [
          "/var/lib/ngnixproxymanager:/data"
          "/var/lib/letsencrypt:/etc/letsencrypt"
        ];

        # The working directory for the container
        workdir = "/var/lib/ngnixproxymanager";

        # Automatically start the ngnixproxymanager container when the system boots
        autoStart = true;
      };
    };
  };
}
