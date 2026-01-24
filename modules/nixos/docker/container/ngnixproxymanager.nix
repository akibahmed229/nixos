# This module deploys the Nginx Proxy Manager (NPM) application via a Docker container,
# handling public HTTP/HTTPS traffic and the administration web interface.
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nm.docker.container.nginxProxyManager;
in {
  # --- 1. Define Options ---
  options.nm.docker.container.nginxProxyManager = {
    enable = mkEnableOption "Enable the Nginx Proxy Manager (NPM) via Docker container";

    image = mkOption {
      type = types.str;
      default = "jc21/nginx-proxy-manager:latest";
      description = "The Docker image for Nginx Proxy Manager.";
    };

    # Host Ports
    hostPortHttp = mkOption {
      type = types.int;
      default = 80;
      description = "Host port for public HTTP access (maps to container port 80).";
    };

    hostPortHttps = mkOption {
      type = types.int;
      default = 443;
      description = "Host port for public HTTPS access (maps to container port 443).";
    };

    hostPortAdmin = mkOption {
      type = types.int;
      default = 8111;
      description = "Host port for the NPM Admin Web interface (maps to container port 81).";
    };

    # Persistence Paths
    dataPath = mkOption {
      type = types.str;
      default = "/var/lib/ngnixproxymanager";
      description = "Host path for NPM data and configuration (/data).";
    };

    certPath = mkOption {
      type = types.str;
      default = "/var/lib/letsencrypt";
      description = "Host path for LetsEncrypt certificates (/etc/letsencrypt).";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 Container Definition
    virtualisation.oci-containers = {
      backend = "docker";

      containers = {
        ngnixproxymanager = {
          image = cfg.image;

          # Map host ports to the container's internal ports
          ports = [
            "${toString cfg.hostPortHttp}:80" # Public HTTP
            "${toString cfg.hostPortHttps}:443" # Public HTTPS
            "${toString cfg.hostPortAdmin}:81" # Admin Web UI
          ];

          # Volume mappings for persistence
          volumes = [
            "${cfg.dataPath}:/data"
            "${cfg.certPath}:/etc/letsencrypt"
          ];

          workdir = cfg.dataPath;
          autoStart = true;
        };
      };
    };

    # 2.2 Open the required ports in the host firewall
    networking.firewall.allowedTCPPorts = [
      cfg.hostPortHttp
      cfg.hostPortHttps
      cfg.hostPortAdmin
    ];
  };
}
