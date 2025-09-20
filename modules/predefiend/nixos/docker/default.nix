{pkgs, ...}: {
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

      # Disable Docker's automatic management of iptables rules, which are responsible for opening ports on the host system.
      # This allows for manual control over port exposure and integration with existing firewall solutions like firewalld or ufw.
      "iptables" = false;

      # Changing Docker Daemon's Data Root
      # data-root = "/some-place/to-store-the-docker-data";
    };

    # start dockerd on boot.
    # This is required for containers which are created with the `--restart=always` flag to work.
    enableOnBoot = true;
  };

  # (Optional but Recommended) Best Practice: Create the Docker network declaratively
  systemd.services.docker-network-level3 = {
    description = "Create Docker network for Level3 routing";
    wantedBy = ["multi-user.target"];
    after = ["docker.service"];
    serviceConfig.Type = "oneshot";
    script = ''
      # check if the network already exists
      if ${pkgs.docker}/bin/docker network inspect level3 > /dev/null 2>&1; then
        echo "Docker network 'level3' already exists. Skipping creation."
      else
        # This command is idempotent; it won't fail if the network already exists
        ${pkgs.docker}/bin/docker  network create -d ipvlan \
          --subnet 192.168.10.0/24 -o parent=enp4s0 \
          -o ipvlan_mode=l3 --subnet 192.168.11.0/24 \
          level3 || true
      fi
    '';
  };

  # desktop must act as a router between LAN and the Docker ipvlan:
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  /*
  * Direct host-to-container access is intentionally restricted by design for isolation,
  * but we can enable clean, direct routing (without redirects or errors) by
  * manually creating an IPvlan L3 subinterface on the host to handle forwarding properly.
  */
  networking.localCommands = ''
    ip link add ipvl-pi link enp4s0 type ipvlan mode l3 || true
    ip link set ipvl-pi up
    ip addr add 192.168.10.1/24 dev ipvl-pi
  '';
}
