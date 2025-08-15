{
  user,
  inputs,
  lib,
  ...
}: let
  secretsInput = builtins.toString inputs.secrets;
  password = lib.strings.trim (builtins.readFile "${secretsInput}/n8n/pass.txt");
in {
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      postgresqln8n = {
        image = "postgres:16";
        volumes = [
          "/var/lib/postgresqln8n/:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_USER = user;
          POSTGRES_PASSWORD = password;
          POSTGRES_DB = "n8n";
        };
        workdir = "/var/lib/postgresqln8n";

        autoStart = true;
      };

      n8n = {
        image = "docker.n8n.io/n8nio/n8n";
        ports = ["5678:5678"];
        volumes = [
          "n8n_data:/home/node/.n8n"
        ];
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
        };
        extraOptions = [
          "--link=postgresqln8n:postgresqln8n"
        ];
        workdir = "/var/lib/n8n_data";

        autoStart = true;
      };
    };
  };
}
