# This module deploys the Pi-hole network-wide ad blocking service
# as a Docker container, configured to use a static IP on a custom network (IPvlan L3).
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nm.docker.container.pihole;
in {
  # --- 1. Define Options ---
  options.nm.docker.container.pihole = {
    enable = mkEnableOption "Enable the Pi-hole network-wide ad blocker via Docker container";

    # Configuration options specific to the Pi-hole setup
    networkName = mkOption {
      type = types.str;
      default = "level3";
      description = "The name of the pre-configured Docker network (e.g., IPvlan L3) to attach Pi-hole to.";
    };

    staticIP = mkOption {
      type = types.str;
      default = "192.168.10.121";
      description = "The static IP address assigned to the Pi-hole container on the custom network.";
    };

    dataPath = mkOption {
      type = types.str;
      default = "/var/lib/pihole";
      description = "The host path for Pi-hole configuration and log data persistence.";
    };

    timeZone = mkOption {
      type = types.str;
      default = "Asia/Dhaka";
      description = "The timezone setting for the container (TZ environment variable).";
    };

    # The Pi-hole web interface password can be set here.
    # NOTE: It's often safer to set this interactively after the container starts using 'docker exec -it pihole pihole -a -p'.
    webPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Optional: Set the WEBPASSWORD environment variable to configure the admin password.";
    };
  };

  /*
  * FIXME: create a network first :
  ```bash
    docker network create -d ipvlan \
        --subnet 192.168.10.0/24 -o parent=enp4s0 \
        -o ipvlan_mode=l3 --subnet 192.168.11.0/24 \
        level3
  ```
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # Ensure Docker OCI backend is enabled
    virtualisation.oci-containers = {
      backend = "docker";

      containers = {
        # --- Pi-hole Container ---
        pihole = {
          image = "pihole/pihole:latest";

          # Since using IPvlan L3 and assigning a static IP,
          # standard port mappings are often not necessary or desirable.
          # The web interface (port 80) and DNS (port 53) will be reachable
          # directly via the static IP (192.168.10.121).
          ports = [
            # Example port mappings if you were NOT using ipvlan:
            # "53:53/tcp"
            # "53:53/udp"
            # "80:80"
          ];

          # Volume mappings to persist Pi-hole configuration data
          volumes = [
            "${cfg.dataPath}:/etc/pihole"
          ];

          # Attach the container to the pre-existing custom Docker network
          networks = [cfg.networkName];

          environment =
            {
              TZ = cfg.timeZone;
              # Listen on all interfaces (necessary for custom networks)
              FTLCONF_dns_listeningMode = "all";
            }
            // (optionalAttrs (cfg.webPassword != null) {
              # Conditionally add the WEBPASSWORD if set in the Nix config
              WEBPASSWORD = cfg.webPassword;
            });

          # Additional Docker options
          extraOptions = [
            # Required capabilities for network management (DHCP, etc.)
            "--cap-add=NET_ADMIN"
            "--cap-add=SYS_TIME"
            "--cap-add=SYS_NICE"
            # Assign the static IP address
            "--ip=${cfg.staticIP}"
          ];

          workdir = cfg.dataPath;
          autoStart = true;
        };
      };
    };
  };
}
