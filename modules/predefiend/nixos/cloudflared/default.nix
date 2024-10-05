{
  pkgs,
  inputs,
  lib,
  ...
}: let
  secretsInput = builtins.toString inputs.mySsecrets;
  token = lib.strings.trim (builtins.readFile "${secretsInput}/cloudflared/token");
in {
  services = {
    cloudflared = {
      enable = true;
      package = pkgs.cloudflared;
    };
  };

  environment.systemPackages = with pkgs; [cloudflared];

  # Ensure the service is enabled so it starts on boot:
  #  $ sudo systemctl enable my_tunnel.service
  systemd.services.my_tunnel = {
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    requires = ["network-online.target"];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=${token}";
      Restart = "on-failure";
      PermissionsStartOnly = true;
      User = "root";
      RemainAfterExit = true;
    };
  };
}
