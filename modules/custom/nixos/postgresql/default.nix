# This module configures a PostgreSQL server instance.
# It allows for easy customization of databases, users, authentication,
# and other server settings. It also includes an option to install pgAdmin4.
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Short-hand for the configuration options of this module.
  cfg = config.nm.postgresql;
in {
  # Define the options that users of this module can set.
  options.nm.postgresql = with lib; {
    enable = mkEnableOption "PostgreSQL server and related tools";

    package = mkOption {
      type = types.package;
      default = pkgs.postgresql;
      defaultText = literalExpression "pkgs.postgresql";
      description = "The PostgreSQL package to use.";
    };

    port = mkOption {
      type = types.port;
      default = 5432;
      description = "The port the PostgreSQL server will listen on.";
    };

    ensureDatabases = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["my_app_db" "another_db"];
      description = "A list of databases to ensure exist when the service starts.";
    };

    authentication = mkOption {
      type = types.lines; # `lines` is a multiline string
      default = ''
        #type  database  user      address         method
        local  all       all                       trust
        host   all       all       127.0.0.1/32    trust
        host   all       all       ::1/128         trust
      '';
      description = "Content for the pg_hba.conf file to control client authentication.";
      example = ''
        # Allow any user to connect from the local machine using scram-sha-256
        # type  database  user      address         method
        host    all       all       127.0.0.1/32    scram-sha-256
      '';
    };

    settings = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        max_connections = "100";
        shared_buffers = "128MB";
      };
      description = "PostgreSQL server settings to be written to postgresql.conf.";
    };

    # Sub-module for pgAdmin configuration.
    pgadmin = {
      enable = mkEnableOption "pgAdmin 4, a PostgreSQL administration GUI";
    };
  };

  /*
  # Example Usage
  ```nix
    # Configure PostgreSQL using the new module
    nm.postgresql = {
      enable = true;
      ensureDatabases = [ "bookDB" ];

      # To enable pgAdmin4, simply uncomment the next line:
      # pgadmin.enable = true;

      # The `authentication` option defaults to the exact configuration
      # you were using, so you don't even need to set it unless you
      # want to change it.
    };
  ```
  */

  # Configure the system based on the options defined above.
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = cfg.package;
      ensureDatabases = cfg.ensureDatabases;

      # Merge user-defined settings with the port setting.
      settings = lib.mkMerge [
        {port = cfg.port;}
        cfg.settings
      ];

      # Use `mkOverride` to ensure this authentication configuration takes precedence.
      authentication = lib.mkOverride 10 cfg.authentication;
    };

    # Add packages to the system environment.
    environment.systemPackages =
      # The main postgresql package provides client tools like `psql`.
      [cfg.package]
      # Conditionally add pgadmin4 if enabled.
      ++ lib.optionals cfg.pgadmin.enable [pkgs.pgadmin4];
  };
}
