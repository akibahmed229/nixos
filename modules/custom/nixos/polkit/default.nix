{
  lib,
  config,
  pkgs,
  ...
}: {
  options.myPolkit.enable = lib.mkEnableOption "Enable a polkit agent";

  config = lib.mkIf config.myPolkit.enable {
    security.polkit.enable = true;

    systemd.user.services.polkit-agent = {
      description = "Polkit authentication agent (auto load)";
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          case 'XDG_CURRENT_DESKTOP' in
            niri|KDE|Plasma|KDE*)
              exec ${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1
              ;;
            Hyprland|GNOME|Unity|X-Cinnamon|MATE|LXDE|XFCE|*)
              exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
              ;;
          esac
        '';
        Restart = "on-failure";
      };
    };
  };
}
