{_, ...}: {
  # Enabling docker
  virtualisation.docker = {
    enable = true; #  To get access to the docker socket, you have to be in the docker group, set the extraGroups attribute to [ "docker" ].
    storageDriver = "btrfs";
    liveRestore = false;
    daemon.settings = {
      /*
      * When connecting to a public Wi-Fi, where the login page's IP-Address is within the Docker network range,
        accessing the Internet might not be possible. This has been reported when trying to connect to the WIFIonICE of the Deutsche Bahn (DB).
        They use the 172.18.x.x address range.

      * This can be resolved by changing the default address pool that Docker uses.
      */
      "default-address-pools" = [
        {
          "base" = "172.27.0.0/16";
          "size" = 24;
        }
      ];

      # enables pulling using containerd, which supports restarting from a partial pull
      # https://docs.docker.com/storage/containerd/
      "features" = {"containerd-snapshotter" = true;};

      # isable Docker's automatic management of iptables rules, which are responsible for opening ports on the host system.
      # This allows for manual control over port exposure and integration with existing firewall solutions like firewalld or ufw.
      # "iptables" = false;

      # Changing Docker Daemon's Data Root
      # data-root = "/some-place/to-store-the-docker-data";
    };

    # start dockerd on boot.
    # This is required for containers which are created with the `--restart=always` flag to work.
    enableOnBoot = true;
  };
}
