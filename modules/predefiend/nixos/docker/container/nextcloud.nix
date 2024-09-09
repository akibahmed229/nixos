{
  user,
  inputs,
  ...
}: let
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
  # Read the password from the secrets file
  secretsInput = builtins.toString inputs.mySsecrets;
  password = inputs.nixpkgs-unstable.lib.strings.trim (builtins.readFile "${secretsInput}/nextcloud/pass.txt");
in {
  # This enables Docker containers as systemd services in NixOS
  virtualisation.oci-containers = {
    backend = "docker";

    # Nextcloud container configuration
    containers = {
      # Optionally, define a MariaDB container for Nextcloud's database
      mariadb = {
        image = "mariadb";

        volumes = [
          "/var/lib/mariadb:/var/lib/mysql" # Persist MariaDB data
        ];

        environment = {
          MYSQL_ROOT_PASSWORD = "${password}";
          MYSQL_DATABASE = "nextcloud";
          MYSQL_USER = "${user}";
          MYSQL_PASSWORD = "${password}";
        };

        workdir = "/var/lib/mariadb";

        autoStart = true;
      };

      # Optionally, define a Redis container for Nextcloud's cache
      redis = {
        image = "redis:alpine";

        autoStart = true;
      };

      nextcloud = {
        image = "nextcloud";

        # Port mappings: exposing HTTP (80) and HTTPS (443) ports
        ports = [
          "8090:80" # enable firewall for this port in order to access
        ];

        # Volume mappings to persist Nextcloud data
        volumes = [
          "/var/lib/nextcloud/html:/var/www/html" # HTML files, Nextcloud config
          "/var/lib/nextcloud/data:/var/www/html/data" # User data
        ];

        # Environment variables for basic configuration
        environment = {
          # Set the database details (assuming you're using MariaDB)
          MYSQL_DATABASE = "nextcloud";
          MYSQL_USER = "${user}";
          MYSQL_PASSWORD = "${password}";
          MYSQL_HOST = "mariadb"; # Link the MariaDB container

          # Redis cache configuration
          REDIS_HOST = "redis"; # Link the Redis container

          # Admin user for Nextcloud
          NEXTCLOUD_ADMIN_USER = "${user}";
          NEXTCLOUD_ADMIN_PASSWORD = "${password}";
        };

        # Linking the database container (optional if using an external DB)
        extraOptions = [
          "--link=mariadb:mariadb" # Assuming MariaDB container is running
          "--link=redis:redis" # Assuming Redis container is running
        ];

        # Working directory for the container
        workdir = "/var/lib/nextcloud/";

        # Automatically start the container on boot
        autoStart = true;
      };

      # Collabora Online (CODE) container
      collabora = {
        image = "collabora/code";

        ports = [
          "9980:9980" # enable firewall for this port in order to access
        ];

        environment = {
          # Disable SSL for local testing (production requires SSL)
          extra_params = "--o:ssl.enable=false";
        };

        autoStart = true;
      };
    };
  };
}
