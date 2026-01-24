{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.openrgb;
in {
  options.hm.openrgb = {
    enable = mkEnableOption "OpenRGB configuration and service";

    server = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to run the OpenRGB SDK server as a background service.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.openrgb];

    # Manage the OpenRGB config folder
    # Uses the 'config' folder in the same directory as this nix file
    xdg.configFile."OpenRGB" = {
      source = ./config;
      recursive = true;
    };

    # Improvement: Run the server in the background so third-party
    # tools can control lighting automatically on boot.
    systemd.user.services.openrgb = mkIf cfg.server.enable {
      Unit = {
        Description = "OpenRGB SDK Server";
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.openrgb}/bin/openrgb --server";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
