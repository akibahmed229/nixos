{
  pkgs,
  lib,
  inputs,
  user,
  ...
}: let
  secretsInput = builtins.toString inputs.secrets;
  domain = lib.strings.trim (builtins.readFile "${secretsInput}/ngrok/domain.txt");
in {
  environment.systemPackages = [pkgs.ngrok];

  systemd.services.ngrok_n8n = {
    wantedBy = ["multi-user.target"];
    after = ["docker-n8n.service"];
    requires = ["docker-n8n.service"];
    serviceConfig = {
      ExecStart = "${pkgs.ngrok}/bin/ngrok http --url=${domain} 5678";
      Restart = "on-failure";
      PermissionsStartOnly = true;
      User = user;
      RemainAfterExit = true;
    };
  };
}
