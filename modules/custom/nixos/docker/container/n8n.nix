# This module deploys the n8n automation server and its dedicated PostgreSQL database
# using Docker containers managed by NixOS.
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nm.docker.container.n8n;
in {
  # --- 1. Define Options ---
  options.nm.docker.container.n8n = {
    enable = mkEnableOption "Enable the n8n automation tool with PostgreSQL backend via Docker containers";

    # Configuration options for the containers
    hostPort = mkOption {
      type = types.int;
      default = 5678;
      description = "The host port to expose the n8n web UI on.";
    };

    defaultUser = mkOption {
      type = types.str;
      default = "n8n";
      description = "The user name for the N8N admin and Postgresql account.";
    };

    dbPassword = mkOption {
      type = types.str;
      default = "123456";
      description = "Passwrd for the N8N DataBase";
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The N8N_EDITOR_BASE_URL Domain";
    };

    postgresDataPath = mkOption {
      type = types.str;
      default = "/var/lib/postgresqln8n";
      description = "The host path for PostgreSQL persistent data.";
    };

    n8nDataVolumeName = mkOption {
      type = types.str;
      default = "n8n_data";
      description = "The Docker volume name for n8n application data.";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # Enable Docker OCI backend
    virtualisation.oci-containers = {
      backend = "docker";

      containers = {
        # --- PostgreSQL Database Container ---
        postgresqln8n = {
          image = "postgres:16";

          volumes = [
            "${cfg.postgresDataPath}:/var/lib/postgresql/data"
          ];

          environment = {
            POSTGRES_USER = cfg.defaultUser; # Reuses 'user' argument passed to module scope
            POSTGRES_PASSWORD = cfg.dbPassword;
            POSTGRES_DB = "n8n";
          };

          workdir = cfg.postgresDataPath;
          autoStart = true;

          # Add a simple health check to ensure PostgreSQL is ready before n8n starts
          extraOptions = [
            "--health-cmd=pg_isready -U ${cfg.defaultUser}"
            "--health-interval=5s"
            "--health-timeout=5s"
            "--health-retries=5"
          ];
        };

        # --- n8n Server Container ---
        n8n = {
          image = "docker.n8n.io/n8nio/n8n";

          # Map the host port to the container's internal port
          ports = ["${toString cfg.hostPort}:5678"];

          # Use a Docker named volume for the application data
          volumes = [
            "${cfg.n8nDataVolumeName}:/home/node/.n8n"
          ];

          environment = {
            GENERIC_TIMEZONE = "Asia/Dhaka";
            TZ = "Asia/Dhaka";
            N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "true";
            N8N_RUNNERS_ENABLED = "true";
            DB_TYPE = "postgresdb";
            DB_POSTGRESDB_DATABASE = "n8n";
            DB_POSTGRESDB_HOST = "postgresqln8n"; # Docker container name acts as hostname
            DB_POSTGRESDB_PORT = "5432";
            DB_POSTGRESDB_USER = cfg.defaultUser;
            DB_POSTGRESDB_PASSWORD = cfg.dbPassword;
            N8N_POSTGRESDB_SYNCHRONIZATION_ATTEMPTS = "10";

            N8N_COMMUNITY_PACKAGES_AL = "true";
            N8N_EDITOR_BASE_URL = cfg.domain;
            WEBHOOK_URL = cfg.domain;
            N8N_DEFAULT_BINARY_DATA_MODE = "filesystem";
          };

          # Link explicitly for dependency and hostname resolution
          extraOptions = [
            "--link=postgresqln8n:postgresqln8n"
          ];

          workdir = "/var/lib/n8n_data";
          autoStart = true;

          # Crucial: ensure the database container starts and is running before n8n tries to connect
          dependsOn = ["postgresqln8n"];
        };
      };
    };
  };
}
