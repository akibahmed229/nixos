{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.mysql;

  # Helper function to get the configuration of the first peer
  firstPeer = head (attrValues cfg.peers);

  # Helper to check if any peer requires permissions to be ensured
  anyPeerNeedsPermissions = any (peer: peer.ensurePermissions) (attrValues cfg.peers);

  # Map peers to NixOS services.mysql.ensureDatabases format
  ensureDatabasesList = map (peer: peer.database) (attrValues cfg.peers);

  # Map peers to NixOS services.mysql.initialDatabases format
  initialDatabasesList = map (
    peer: {
      name = peer.database;
      schema = mkIf (peer.schemaFile != null) peer.schemaFile;
    }
  ) (attrValues cfg.peers);

  # Map peers to NixOS services.mysql.ensureUsers format
  ensureUsersList = map (
    peer: {
      name = peer.username;
      ensurePermissions = mkIf peer.ensurePermissions {
        "${peer.database}.*" = "ALL PRIVILEGES";
      };
    }
  ) (attrValues cfg.peers);
in {
  # --- 1. Define Options ---
  options.nm.mysql = {
    en = mkEnableOption "Enable and configure the MySQL/MariaDB database service.";

    package = mkOption {
      type = types.package;
      default = pkgs.mariadb;
      description = "The package to use for the MySQL server.";
    };

    enClientTools = mkEnableOption "Install the command line MySQL client package.";
    enWorkbench = mkEnableOption "Install MySQL Workbench for GUI management.";

    peers = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          database = mkOption {
            type = types.str;
            description = "The database name to create and configure.";
          };
          username = mkOption {
            type = types.str;
            description = "The username to create for this database.";
          };
          password = mkOption {
            type = types.str;
            description = "The password for the user. USE SOPS FOR REAL SECRETS!";
          };
          schemaFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Optional path to a .sql file to initialize the schema.";
          };
          ensurePermissions = mkOption {
            type = types.bool;
            default = true;
            description = "If true, grants ALL PRIVILEGES to the user on the database.";
          };
        };
      });
      default = {};
      description = "Attribute set of database/user pairs to configure.";
    };

    replication = {
      en = mkEnableOption "Enable MySQL replication settings.";
      role = mkOption {
        type = types.enum ["master" "slave"];
        default = "master";
        description = "Replication role (master or slave).";
      };
      slaveHost = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "The slave host IP address for master configuration.";
      };
      masterUser = mkOption {
        type = types.str;
        default = firstPeer.username;
        description = "The username used for replication (defaults to the first peer's user).";
      };
      masterPassword = mkOption {
        type = types.str;
        default = firstPeer.password;
        description = "The password used for replication (defaults to the first peer's password).";
      };
    };
  };

  /*
  # Example Usage
  ```nix
  # In your configuration.nix or relevant host file:

  { config, pkgs, ... }:

  {
    imports = [
      # ... other modules
      ./modules/mysql.nix
    ];

    nm.mysql = {
      en = true;

      # Optional: Set the package to mariadb (already the default)
      package = pkgs.mariadb;

      # Optional: Enable the GUI tool and CLI client
      enClientTools = true;
      enWorkbench = true;

      # 1. Define the databases, users, and permissions using peers
      peers = {
        stats = {
          database = "test1";
          username = "akib";
          password = "123"; # Reminder: Use SOPS or a secure vault for real passwords!

          # 'ensurePermissions = true' triggers ALL PRIVILEGES grant (via the generated Systemd service)
          ensurePermissions = true;

          # Optional: path to an initial schema file (if needed)
          # schemaFile = ./sql/main.sql;
        };
      };

      # 2. Replication configuration
      replication = {
        en = true;
        role = "master";
        slaveHost = "127.0.0.1";
        # masterUser/masterPassword automatically default to 'akib'/'123' from the 'stats' peer.
      };
    };
  }
  ```
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.en {
    # 2.1 Core MySQL Service
    services.mysql = {
      package = cfg.package;
      enable = true;

      # Databases and Users from peers
      ensureDatabases = ensureDatabasesList;
      initialDatabases = initialDatabasesList;
      ensureUsers = ensureUsersList;

      # Replication settings
      replication = mkIf cfg.replication.en {
        inherit (cfg.replication) role slaveHost;
        masterUser = cfg.replication.masterUser;
        masterPassword = cfg.replication.masterPassword;
      };
    };

    # 2.2 Systemd Service to Grant Permissions
    # Only create this service if at least one peer is defined AND requires permission setup.
    systemd.services.nm-mysql-permission-setup = mkIf (anyPeerNeedsPermissions && cfg.peers != {}) {
      description = "MySQL database permission setup for nm.mysql peers";
      wants = ["mariadb.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        # Command to grant permissions for all peers that requested it
        ExecStart = optionalString anyPeerNeedsPermissions (
          concatStringsSep " " (
            map (peer: ''
              ${cfg.package}/bin/mysql -e "
                GRANT ALL PRIVILEGES ON ${peer.database}.*
                TO '${peer.username}'@'localhost'
                IDENTIFIED BY '${peer.password}';
              "
            '') (attrValues (filterAttrs (n: peer: peer.ensurePermissions) cfg.peers))
          )
        );
        User = "root";
        PermissionsStartOnly = true;
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };

    # 2.3 Environment Packages
    environment.systemPackages = with pkgs;
      optionals cfg.enClientTools [
        cfg.package # Provides the client tools (mysql command)
      ]
      ++ optionals cfg.enWorkbench [
        mysql-workbench
      ];
  };
}
