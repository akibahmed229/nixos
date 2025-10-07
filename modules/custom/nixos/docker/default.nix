# This module encapsulates advanced Docker configuration, including daemon settings,
# custom network creation (IPvlan L3), IP forwarding, and firewall rules.
{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nm.docker;
  # Helper function to quote strings for shell scripts (useful for paths and names)
  shellQuote = str: lib.strings.escapeNixString str;
in {
  # --- 1. Define Options ---
  options.nm.docker = {
    enable = mkEnableOption "Enable advanced Docker configuration with custom network settings";

    iptables.enable = lib.mkOption {
      type = lib.types.bool;
      default = true; # Set the default to true
      description = "Docker's automatic management of iptables rules";
    };

    # Options for the custom IPvlan L3 network setup
    ipvlan = {
      enable = mkEnableOption "Enable IPvlan L3 network setup";

      networkName = mkOption {
        type = types.str;
        default = "level3";
        description = "The name of the custom Docker IPvlan network.";
      };

      parentInterface = mkOption {
        type = types.str;
        default = "enp4s0"; # Based on your current config
        description = "The host interface to use as the parent for the IPvlan network.";
      };

      subnets = mkOption {
        type = types.listOf types.str;
        default = ["192.168.10.0/24" "192.168.11.0/24"];
        description = "List of subnets to use for the IPvlan network (e.g., ['192.168.10.0/24']).";
      };

      hostIP = mkOption {
        type = types.str;
        default = "192.168.10.1/24";
        description = "The IP address assigned to the host's virtual IPvlan interface for direct routing.";
      };
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1. Basic Docker Service Configuration
    virtualisation.docker = {
      enable = true;
      storageDriver = "btrfs";
      liveRestore = false;
      enableOnBoot = true;

      daemon.settings = {
        # Custom address pool to avoid conflicts with common Wi-Fi networks (e.g., 172.18.x.x)
        "default-address-pools" = [
          {
            "base" = "172.27.0.0/16";
            "size" = 24;
          }
        ];

        # Enables pulling using containerd snapshotter
        "features" = {"containerd-snapshotter" = true;};

        # Disable Docker's automatic management of iptables rules
        "iptables" = cfg.iptables.enable;
      };
    };

    # 2.2. IP Forwarding (Router Functionality)
    # Required for the host to act as a router between LAN and Docker networks
    boot.kernel.sysctl = lib.mkDefault {
      "net.ipv4.ip_forward" = 1;
    };

    # 2.3. IPvlan L3 Network Setup

    # A. Systemd Service to Create the Docker Network
    # This service ensures the custom IPvlan network is created declaratively on boot.
    systemd.services.docker-network-ipvlan-l3 = mkIf cfg.ipvlan.enable {
      description = "Create Docker IPvlan L3 network: ${cfg.ipvlan.networkName}";
      wantedBy = ["multi-user.target"];
      after = ["docker.service"];
      serviceConfig.Type = "oneshot";

      script = let
        # Build the subnet arguments for the docker network create command
        subnetArgs = lib.concatStringsSep " " (map (s: "--subnet ${shellQuote s}") cfg.ipvlan.subnets);
      in ''
        DOCKER=${pkgs.docker}/bin/docker

        # Check if the network already exists
        if $DOCKER network inspect ${shellQuote cfg.ipvlan.networkName} > /dev/null 2>&1; then
          echo "Docker network '${shellQuote cfg.ipvlan.networkName}' already exists. Skipping creation."
        else
          echo "Creating Docker IPvlan L3 network: ${shellQuote cfg.ipvlan.networkName}"

          # Create the network
          $DOCKER network create -d ipvlan \
            -o parent=${shellQuote cfg.ipvlan.parentInterface} \
            -o ipvlan_mode=l3 \
            ${subnetArgs} \
            ${shellQuote cfg.ipvlan.networkName} || true
        fi
      '';
    };

    # B. Host Configuration for Direct Container Routing
    # Creates the virtual L3 interface on the host for clean routing.
    networking.localCommands = mkIf cfg.ipvlan.enable ''
      IFACE="ipvl-" # ipvl-enp4s0
      PARENT="${shellQuote cfg.ipvlan.parentInterface}"
      HOST_IP="${shellQuote cfg.ipvlan.hostIP}"

      # Add the IPvlan link (ignore if it already exists)
      ip link add "$IFACE" link "$PARENT" type ipvlan mode l3 || true

      # Set the interface up
      ip link set "$IFACE" up

      # Assign the host's IP address to this virtual interface
      ip addr add "$HOST_IP" dev "$IFACE"
    '';

    # C. Firewall Rules for NAT and Forwarding
    # These rules allow the Docker containers to reach the internet (MASQUERADE)
    # and allow traffic forwarding (FORWARD) between the host and container network.
    networking.firewall.extraCommands = mkIf cfg.ipvlan.enable ''
      # Variables for clarity in the script
      DOCKER_BASE="172.27.0.0/16"
      LAN_IFACE="${shellQuote cfg.ipvlan.parentInterface}"

      # 1. NAT (Masquerade): Rewrite container source IPs to the host’s IP
      #    so containers can reach the internet. Uses the custom default address pool.
      #    NOTE: The custom pool takes precedence over docker0, but we allow both
      #    for safety. Using the parent interface for -o.
      iptables -t nat -A POSTROUTING -s $DOCKER_BASE -o $LAN_IFACE -j MASQUERADE
      iptables -t nat -A POSTROUTING -s 172.17.0.0/16 -o $LAN_IFACE -j MASQUERADE # Standard docker0


      # 2. FORWARD: Allow traffic forwarding
      # Allow traffic from containers (Docker networks) to the internet (LAN interface)
      iptables -A FORWARD -i docker0 -o $LAN_IFACE -j ACCEPT

      # Allow return traffic: internet -> containers (for established connections)
      iptables -A FORWARD -i $LAN_IFACE -o docker0 -m state --state ESTABLISHED,RELATED -j ACCEPT
    '';
  };
}
