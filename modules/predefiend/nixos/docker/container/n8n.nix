{
  user,
  inputs,
  lib,
  ...
}:
/*
# General Instructions:
# To access the server: http://localhost:5678

    * Enter into postgresql container to check the database
            $ docker exec -it postgresqln8n bash
            $ psql -U akib -d n8n
*/
let
  # Read the password from the secrets file
  secretsInput = builtins.toString inputs.secrets;
  password = lib.strings.trim (builtins.readFile "${secretsInput}/n8n/pass.txt");
  domain = lib.strings.trim (builtins.readFile "${secretsInput}/ngrok/domain.txt");
in {
  # This enables Docker containers as systemd services in NixOS
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      # Define POstgresql container for n8n database
      postgresqln8n = {
        image = "postgres:16";

        # Volume mappings to persist n8n data outside the container
        volumes = [
          "/var/lib/postgresqln8n/:/var/lib/postgresql/data"
        ];

        # Environment variables for configuration
        environment = {
          POSTGRES_USER = user;
          POSTGRES_PASSWORD = password;
          POSTGRES_DB = "n8n";
        };

        # Working directory for the container
        workdir = "/var/lib/postgresqln8n";

        # Automatically start the container on boot
        autoStart = true;
      };

      #  n8n container image configuration
      n8n = {
        image = "docker.n8n.io/n8nio/n8n";

        # Port mappings to allow external devices to access n8n services
        ports = ["5678:5678"];

        # Volume mappings to persist n8n data
        volumes = [
          "n8n_data:/home/node/.n8n"
        ];

        # Environment variables for configuration
        environment = {
          GENERIC_TIMEZONE = "Asia/Dhaka";
          TZ = "Asia/Dhaka";
          N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "true";
          N8N_RUNNERS_ENABLED = "true";
          DB_TYPE = "postgresdb";
          DB_POSTGRESDB_DATABASE = "n8n";
          DB_POSTGRESDB_HOST = "postgresqln8n"; # hostname = container name
          DB_POSTGRESDB_PORT = "5432";
          DB_POSTGRESDB_USER = user;
          DB_POSTGRESDB_PASSWORD = password;
          N8N_POSTGRESDB_SYNCHRONIZATION_ATTEMPTS = "10";

          N8N_COMMUNITY_PACKAGES_AL = "true";
          N8N_EDITOR_BASE_URL = domain;
          WEBHOOK_URL = domain;
          N8N_DEFAULT_BINARY_DATA_MODE = "filesystem";
        };

        # Linking the database container (optional if using an external DB)
        extraOptions = [
          "--link=postgresqln8n:postgresqln8n"
        ];

        # Working directory for the container
        workdir = "/var/lib/n8n_data";

        # Automatically start the container on boot
        autoStart = true;
      };
    };
  };
}
