# This module deploys the AdGuard Home network-wide DNS sinkhole
# as a Docker container, configured to use a static IP on a custom network (IPvlan L3).
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nm.docker.container.adguard;
in {
  # --- 1. Define Options ---
  options.nm.docker.container.adguard = {
    enable = mkEnableOption "Enable the AdGuard Home DNS sinkhole via Docker container";

    image = mkOption {
      type = types.str;
      default = "adguard/adguardhome:latest"; # Consider pinning to a specific version for reproducibility, e.g., "adguard/adguardhome:v0.107.45"
      description = "The Docker image to use for AdGuard Home.";
    };

    networkName = mkOption {
      type = types.str;
      default = "level3"; # Matches your Pi-hole setup
      description = "The name of the pre-configured Docker network (e.g., IPvlan L3) to attach AdGuard Home to.";
    };

    staticIP = mkOption {
      type = types.str;
      default = "192.168.10.122"; # Assign a *different* IP than Pi-hole on the same subnet
      description = "The static IP address assigned to the AdGuard Home container on the custom network.";
    };

    workDataPath = mkOption {
      type = types.str;
      default = "/var/lib/adguardhome/work";
      description = "The host path for AdGuard Home working data (query logs, statistics).";
    };

    confDataPath = mkOption {
      type = types.str;
      default = "/var/lib/adguardhome/conf";
      description = "The host path for AdGuard Home configuration files.";
    };

    timeZone = mkOption {
      type = types.str;
      default = "Asia/Dhaka";
      description = "The timezone setting for the container (TZ environment variable).";
    };
  };

  /*
  * REMINDER: The custom Docker network must be created manually first!
  * Example (adjust subnet/parent if needed):
  * ```bash
  * docker network create -d ipvlan \
  * --subnet 192.168.10.0/24 -o parent=enp4s0 \
  * -o ipvlan_mode=l3 \
  * level3
  * ```
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # Ensure Docker OCI backend is enabled (likely already enabled by Pi-hole)
    virtualisation.oci-containers = {
      backend = "docker";

      containers = {
        # --- AdGuard Home Container ---
        adguardhome = {
          image = cfg.image;
          autoStart = true;

          # Volume mappings for persistent configuration and data
          volumes = [
            "${cfg.workDataPath}:/opt/adguardhome/work"
            "${cfg.confDataPath}:/opt/adguardhome/conf"
          ];

          # Attach the container to the pre-existing custom Docker network
          networks = [cfg.networkName];

          # No standard port mappings needed due to IPvlan and static IP.
          # AdGuard will be reachable directly at cfg.staticIP on its standard ports:
          # - DNS: 53 (TCP/UDP)
          # - Admin UI: 80 (TCP, redirects to setup/login) or 443 if configured
          # - Initial Setup: 3000 (TCP)
          # - DNS-over-TLS: 853 (TCP/UDP)
          # - DNS-over-QUIC: 784, 853, 8853 (UDP)
          # - DNSCrypt: 5443 (TCP/UDP)
          ports = [];

          environment = {
            TZ = cfg.timeZone;
          };

          # Additional Docker options
          extraOptions = [
            # Assign the static IP address
            "--ip=${cfg.staticIP}"
            # Capabilities needed for DNS/DHCP functionality
            "--cap-add=NET_ADMIN" # Often needed for low ports and advanced networking
            "--cap-add=SYS_NICE" # Allows optimizing process priority
            # Consider adding "--cap-add=NET_RAW" if you plan to use AdGuard's DHCP server features
          ];
        };
      };
    };

    # --- Firewall Reminder ---
    # If clients outside your host machine need to reach AdGuard Home's DNS
    # (port 53 UDP/TCP) or Web UI (port 80/443 TCP), ensure your NixOS
    # host firewall allows this traffic to the container's static IP.
    # Example (add to your main NixOS firewall config):
    # networking.firewall.allowedTCPPorts = [ 80 443 ];
    # networking.firewall.allowedUDPPorts = [ 53 ];
    # networking.firewall.allowedTCPPorts = [ 53 ]; # DNS over TCP
  };
}
