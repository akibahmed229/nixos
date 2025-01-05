{
  /*
  # General introduction
  # Access the portainer web interface by visiting https://localhost:9443
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
      gitea = {
        image = "docker.io/gitea/gitea:1.22.6-rootless";

        # Port mappings to allow external devices to access gitea web interface
        ports = [
          "3333:3000"
          "2222:2222"
        ];

        # Volume mappings to persist gitea data outside the container
        volumes = [
          "/mnt/sda1/Akib/DockerDB/data/gitea:/var/lib/gitea"
          "/mnt/sda1/Akib/DockerDB/config:/etc/gitea"
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
        ];

        # Automatically start the gitea container when the system boots
        autoStart = true;
      };
    };
  };
}
