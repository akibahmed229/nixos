{
  pkgs,
  unstable,
  ...
}: let
  statsConfig = {
    db = "test1";
    user = "akib";
    password = "123";
  };
in {
  services.mysql = {
    package = pkgs.mariadb;
    enable = true;
    ensureDatabases = [
      statsConfig.db
    ];
    replication = {
      role = "master";
      slaveHost = "127.0.0.1";
      masterUser = "${statsConfig.user}";
      masterPassword = "${statsConfig.password}";
    };
    initialDatabases = [
      {
        name = "${statsConfig.db}";
        # schema = ./main.sql;
      }
    ];
    # initialScript = ./main.sql;
    ensureUsers = [
      {
        name = "${statsConfig.user}";
        ensurePermissions = {
          "${statsConfig.db}.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  environment.systemPackages = with unstable.${pkgs.system}; [
    mysql80 # MySQL database.
    mysql-workbench # MySQL database design tool.
  ];

  systemd.services.setdbpass = {
    description = "MySQL database password setup";
    wants = ["mariadb.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.mariadb}/bin/mysql -e "grant all privileges on ${statsConfig.db}.* to ${statsConfig.user}@localhost identified by '${statsConfig.password}';" ${statsConfig.db}
      '';
      User = "root";
      PermissionsStartOnly = true;
      RemainAfterExit = true;
    };
  };
}
