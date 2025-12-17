# This module deploys the Portainer Community Edition (CE) container
# for managing Docker, utilizing a persistent data volume and exposing
# the required web interface ports.
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nm.docker.container.portainer;
in {
  # --- 1. Define Options ---
  options.nm.docker.container.portainer = {
    enable = mkEnableOption "Enable the Portainer Community Edition (CE) container management UI";

    # Configuration options for the Portainer container
    hostPortHttp = mkOption {
      type = types.int;
      default = 8010; # Maps to container port 8000
      description = "The host port for HTTP access (default non-secure API port).";
    };

    hostPortHttps = mkOption {
      type = types.int;
      default = 9443; # Maps to container port 9443
      description = "The host port for HTTPS web interface access.";
    };

    dataPath = mkOption {
      type = types.str;
      default = "/var/lib/portainer";
      description = "The host path for Portainer persistent data storage.";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # Ensure Docker OCI backend is enabled
    virtualisation.oci-containers = {
      backend = "docker";

      containers = {
        # --- Portainer CE Container ---
        portainer = {
          image = "portainer/portainer-ce:latest";

          # Port mappings
          ports = [
            "${toString cfg.hostPortHttp}:8000" # Internal API/Redirect Port
            "${toString cfg.hostPortHttps}:9443" # Main HTTPS Web UI Port
          ];

          # Volume mappings
          volumes = [
            # Access to the Docker socket is required for Portainer to manage the local Docker host
            "/var/run/docker.sock:/var/run/docker.sock"
            # Persistent storage for Portainer configuration and settings
            "${cfg.dataPath}:/data"
          ];

          workdir = cfg.dataPath;

          # Automatically start the Portainer container on boot
          autoStart = true;

          # Optional: Add a simple health check to monitor the container status
          extraOptions = [
            # "--health-cmd=wget --no-check-certificate --quiet --tries=1 --timeout=5 -O /dev/null https://localhost:9443/health"
            "--health-interval=10s"
            "--health-timeout=10s"
            "--health-retries=5"
          ];
        };
      };
    };
  };
}
