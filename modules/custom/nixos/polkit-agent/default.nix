{ lib, config, pkgs, ... }:
let
  cfg = config.polkit-gnome;
in
{
  options = {
    polkit-gnome = {
      enable = lib.mkEnableOption "Enable the main user module";
    };
  };

  config = lib.mkIf cfg.enable {
    security.polkit = {
      enable = true;
    };
    # A dbus session bus service that is used to bring up authentication dialogs used by polkit and gnome-keyring 
    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };
}

