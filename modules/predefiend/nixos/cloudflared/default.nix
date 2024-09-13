{
  pkgs,
  unstable,
  inputs,
  ...
}: let
  secretsInput = builtins.toString inputs.mySsecrets;
  token = inputs.nixpkgs-unstable.lib.strings.trim (builtins.readFile "${secretsInput}/cloudflared/token");
in {
  services = {
    cloudflared = {
      enable = true;
      package = unstable.${pkgs.system}.cloudflared;
    };
  };

  environment.systemPackages = with unstable.${pkgs.system}; [cloudflared];

  # Ensure the service is enabled so it starts on boot:
  #  $ sudo systemctl enable my_tunnel.service
  systemd.services.my_tunnel = {
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    requires = ["network-online.target"];
    serviceConfig = {
      ExecStart = "${unstable.${pkgs.system}.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=${token}";
      Restart = "on-failure";
      PermissionsStartOnly = true;
      User = "root";
      RemainAfterExit = true;
    };
  };
}
