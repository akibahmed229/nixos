{ lib
, stdenv
, pkgs
, ...
}:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
    settings.port = 5432;
    ensureDatabases = [ "bookDB" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      # IPv4 local connections:
      host    all             all             127.0.0.1/32            trust
      # IPv6 local connections:
      host    all             all             ::1/128                 trust

    '';
  };
}
