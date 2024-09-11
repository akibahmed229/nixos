{
  /*
  # General introduction
  # portainer is a lightweight management UI which allows you to easily manage your Docker host or Swarm cluster
  # You can use portainer to manage containers, images, networks, and volumes

  # You can access the portainer web interface by visiting http://localhost:8010
  # you can also manage remote docker & kubernetes clusters using portainer
  */
  # This enables Docker containers as systemd services in NixOS
  virtualisation.oci-containers = {
    # Docker is used as the backend for container management
    backend = "docker";

    # Defining the containers section
    containers = {
      portainer = {
        image = "portainer/portainer-ce:2.21.1";

        # Port mappings to allow external devices to access portainer web interface
        ports = [
          "8010:8000"
          "9443:9443"
        ];

        # Volume mappings to persist portainer data outside the container
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "/var/lib/portainer:/data"
        ];

        # The working directory for the container
        workdir = "/var/lib/portainer";

        # Automatically start the portainer container when the system boots
        autoStart = true;
      };
    };
  };
}
