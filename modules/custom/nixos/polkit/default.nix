{
  lib,
  config,
  pkgs,
  ...
}: {
  options.nm.myPolkit.enable = lib.mkEnableOption "Enable a polkit agent";

  config = lib.mkIf config.nm.myPolkit.enable {
    security.polkit.enable = true;

    systemd.user.services.polkit-agent = {
      description = "Polkit authentication agent (auto load)";
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeShellScript "polkit-agent" ''
          #!/usr/bin/env bash

          case "$XDG_CURRENT_DESKTOP" in
            KDE|Plasma|KDE*)
              exec ${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1
              ;;
            niri|Hyprland|GNOME|Unity|X-Cinnamon|MATE|LXDE|XFCE|*)
              exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
              ;;
          esac
        '';
        Restart = "on-failure";
      };
    };
  };
}
