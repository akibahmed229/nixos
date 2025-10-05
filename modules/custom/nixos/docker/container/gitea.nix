# This module deploys the Gitea code hosting service via a Docker container.
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nm.docker.container.gitea;
in {
  # --- 1. Define Options ---
  options.nm.docker.container.gitea = {
    enable = mkEnableOption "Enable the Gitea code hosting solution via Docker container";

    # Host Ports
    hostPortWeb = mkOption {
      type = types.int;
      default = 3333;
      description = "Host port exposed for the Gitea web interface (maps to container port 3000).";
    };

    hostPortSsh = mkOption {
      type = types.int;
      default = 2222;
      description = "Host port exposed for Gitea SSH access (maps to container port 2222).";
    };

    # Persistence Paths
    dataRoot = mkOption {
      type = types.str;
      default = "/var/lib/gitea/data";
      description = "Host path for Gitea data persistence (/var/lib/gitea).";
    };

    configRoot = mkOption {
      type = types.str;
      default = "/var/lib/gitea/config";
      description = "Host path for Gitea configuration persistence (/etc/gitea).";
    };

    image = mkOption {
      type = types.str;
      default = "docker.io/gitea/gitea:1.22.6-rootless";
      description = "The Gitea Docker image to use.";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 Container Definition
    virtualisation.oci-containers = {
      backend = "docker";

      containers = {
        gitea = {
          image = cfg.image;

          # Map host ports to the container's internal ports (3000 for web, 2222 for SSH)
          ports = [
            "${toString cfg.hostPortWeb}:3000"
            "${toString cfg.hostPortSsh}:2222"
          ];

          # Volume mappings for persistence and timezone
          volumes = [
            "${cfg.dataRoot}:/var/lib/gitea"
            "${cfg.configRoot}:/etc/gitea"
            "/etc/timezone:/etc/timezone:ro"
            "/etc/localtime:/etc/localtime:ro"
          ];

          # Gitea uses rootless mode by default in this image
          autoStart = true;
        };
      };
    };

    # 2.2 Open the required ports in the host firewall
    networking.firewall.allowedTCPPorts = [
      cfg.hostPortWeb # Web UI access
      cfg.hostPortSsh # SSH access for Git
    ];
  };
}
