# This module deploys the Nextcloud stack, including MariaDB for the database,
# Redis for caching, and optionally Collabora Online (CODE) for document editing.
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nm.docker.container.nextcloud;
in {
  # --- 1. Define Options ---
  options.nm.docker.container.nextcloud = {
    enable = mkEnableOption "Enable the Nextcloud file synchronization and sharing stack";
    enablePort = mkEnableOption "Enable the Nextcloud Port to Access in Local Network";

    password = mkOption {
      type = types.str;
      description = "The nextcloud password";
      default = "123456";
    };

    defaultUser = mkOption {
      type = types.str;
      default = "nextcloud-admin";
      description = "The user name for the Nextcloud admin and MariaDB account.";
    };

    hostPort = mkOption {
      type = types.int;
      default = 8090;
      description = "The host port exposed for the Nextcloud web interface (maps to container port 80).";
    };

    # Persistence Paths
    htmlRoot = mkOption {
      type = types.str;
      default = "/var/lib/nextcloud/html";
      description = "The host path for Nextcloud HTML files and config.";
    };
    dataRoot = mkOption {
      type = types.str;
      default = "/var/lib/nextcloud/data";
      description = "The host path for Nextcloud user data.";
    };
    mariadbRoot = mkOption {
      type = types.str;
      default = "/var/lib/mariadb";
      description = "The host path for MariaDB data persistence.";
    };

    # Optional Collabora Integration
    enableCollabora = mkEnableOption "Enable the Collabora Online (CODE) container";
    collaboraHostPort = mkOption {
      type = types.int;
      default = 9980;
      description = "The host port exposed for the Collabora Online server.";
    };
  };

  /*
  # General Instructions:

   *  Note: to add trusted domains, edit the config.php file in the Nextcloud container.
            $ sudo nvim /var/lib/nextcloud/html/config/config.php

            Example:
             'trusted_domains' =>
             array (
               0 => 'localhost',
               1 => 'nextcloud.example.com',
             ),

    *  Note: to enable Collabora Online (CODE) integration, configure the Nextcloud server with the Collabora Online app.
            - Go to the Nextcloud admin panel and install the Collabora Online app.
            - In the Nextcloud admin panel, go to Collabora Online settings and enter the Collabora Online server URL (e.g., http://yourIP:9980).
            - Save the settings and Collabora Online should be enabled for Nextcloud.

    * Enter into mariadb container to check the database
            $ docker exec -it mariadb bash
            $ mariadb -u root -p
            $ show databases;
            $ use nextcloud;
            $ show tables;
            $ select * from oc_users;
            $ exit;

    * For Redis cache, enter into redis container
            $ docker exec -it redis sh
            $ redis-cli
            $ keys *
            $ exit

    * For Collabora Online (CODE) container
            $ docker exec -it collabora bash
            $ loolwsd-admin list
            $ exit
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 Container Definitions (MariaDB, Redis, Nextcloud, and optional Collabora)
    virtualisation.oci-containers = {
      backend = "docker";

      containers =
        {
          # 1. MariaDB Container (Database)
          mariadb = {
            image = "mariadb:latest";
            volumes = [
              "${cfg.mariadbRoot}:/var/lib/mysql" # Persist MariaDB data
            ];
            environment = {
              MYSQL_ROOT_PASSWORD = cfg.password;
              MYSQL_DATABASE = "nextcloud";
              MYSQL_USER = cfg.defaultUser;
              MYSQL_PASSWORD = cfg.password;
            };
            workdir = cfg.mariadbRoot;
            autoStart = true;
          };

          # 2. Redis Container (Caching)
          redis = {
            image = "redis:alpine";
            autoStart = true;
          };

          # 3. Nextcloud Container (Application)
          nextcloud = {
            image = "nextcloud:latest";
            ports = [
              "${toString cfg.hostPort}:80"
            ];
            volumes = [
              "${cfg.htmlRoot}:/var/www/html" # HTML files, Nextcloud config
              "${cfg.dataRoot}:/var/www/html/data" # User data
            ];
            environment =
              {
                # Database Configuration (links to mariadb container name)
                MYSQL_DATABASE = "nextcloud";
                MYSQL_USER = cfg.defaultUser;
                MYSQL_PASSWORD = cfg.password;
                MYSQL_HOST = "mariadb";

                # Redis Cache Configuration (links to redis container name)
                REDIS_HOST = "redis";

                # Admin user setup
                NEXTCLOUD_ADMIN_USER = cfg.defaultUser;
                NEXTCLOUD_ADMIN_PASSWORD = cfg.password;

                # Collabora Online configuration (required for Nextcloud to connect to CODE)
                # Setting this environment variable is optional, but helps if Collabora is also enabled
              }
              // (optionalAttrs cfg.enableCollabora {
                # The public URL for the Collabora server
                VIRTUAL_HOST = "collabora";
              });

            extraOptions = [
              "--link=mariadb:mariadb"
              "--link=redis:redis"
            ];
            workdir = cfg.htmlRoot;
            autoStart = true;

            # Ensure the database and cache are up before starting Nextcloud
            dependsOn = ["mariadb" "redis"];
          };
        }
        // (optionalAttrs cfg.enableCollabora {
          # 4. Collabora Online (CODE) Container (Optional)
          collabora = {
            image = "collabora/code:latest";
            ports = [
              "${toString cfg.collaboraHostPort}:9980"
            ];
            environment = {
              # Disable SSL for local testing (production requires SSL)
              extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
            };
            autoStart = true;
            # Collabora doesn't strictly depend on Nextcloud, but we ensure the reverse link is not needed here.
          };
        });
    };

    # 2.2 Open the required ports in the host firewall
    networking.firewall.allowedTCPPorts =
      optional cfg.enablePort
      ([
          cfg.hostPort # Nextcloud Web UI
        ]
        ++ (optional cfg.enableCollabora cfg.collaboraHostPort));
  };
}
