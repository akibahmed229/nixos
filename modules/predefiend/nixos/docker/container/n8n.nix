{
  user,
  inputs,
  lib,
  ...
}: let
  # Read the password from the secrets file
  secretsInput = builtins.toString inputs.secrets;
  password = lib.strings.trim (builtins.readFile "${secretsInput}/n8n/pass.txt");
in {
  /*
  # General Instructions:
  # To access the server: http://localhost:5678
  */

  # This enables Docker containers as systemd services in NixOS
  virtualisation.oci-containers = {
    backend = "docker";

    postgresqln8n = {
      image = "postgres:16";
      ports = ["5442:5432"]; # optional if you want external DB access
      volumes = [
        "/var/lib/postgresqln8n:/var/lib/postgresql/data"
      ];
      environment = {
        POSTGRES_USER = "${user}";
        POSTGRES_PASSWORD = "${password}";
        POSTGRES_DB = "n8n";
      };
      networks = ["n8n-net"];
      autoStart = true;
    };

    n8n = {
      image = "docker.n8n.io/n8nio/n8n";
      ports = ["5678:5678"];
      volumes = [
        "/var/lib/n8n_data:/home/node/.n8n"
      ];
      environment = {
        GENERIC_TIMEZONE = "Asia/Dhaka";
        TZ = "Asia/Dhaka";
        N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "true";
        N8N_RUNNERS_ENABLED = "true";
        DB_TYPE = "postgresdb";
        DB_POSTGRESDB_DATABASE = "n8n";
        DB_POSTGRESDB_HOST = "postgresqln8n"; # matches container name
        DB_POSTGRESDB_PORT = "5442";
        DB_POSTGRESDB_USER = "${user}";
        DB_POSTGRESDB_PASSWORD = "${password}";
      };
      networks = ["n8n-net"];
      autoStart = true;
    };

    n8n-net.networks = {};
  };
}
