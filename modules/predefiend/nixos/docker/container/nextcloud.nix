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

    * Enter into mariadb container to check the database
            $ docker exec -it mariadb bash
            $ mariadb -u root -p
            $ show databases;
            $ use nextcloud;
            $ show tables;
            $ select * from oc_users;
            $ exit;
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
        autoStart = true;
      };

      nextcloud = {
        image = "nextcloud";

        # Port mappings: exposing HTTP (80) and HTTPS (443) ports
        ports = [
          "8090:80"
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

          # Admin user for Nextcloud
          NEXTCLOUD_ADMIN_USER = "${user}";
          NEXTCLOUD_ADMIN_PASSWORD = "${password}";

          TZ = "Asia/Dhaka"; # Set your timezone
        };

        # Linking the database container (optional if using an external DB)
        extraOptions = [
          "--link=mariadb:mariadb" # Assuming MariaDB container is running
        ];

        # Working directory for the container
        workdir = "/var/www/html";

        # Automatically start the container on boot
        autoStart = true;
      };
    };
  };
}
