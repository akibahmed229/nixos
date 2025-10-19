# virt home-manager configuration
{
  pkgs,
  self,
  lib,
  user,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms =
      [
        "firefox"
        "nvim"
        "thunar"
      ]
      ++ lib.optionals (user == "akib") [
        "git"
        "sops"
        "ssh"
      ];
  };

  home.packages = with pkgs; [
    # 1. Screenshot & Screen Tools
    xclip
    klipper

    # 2. Utility
    udiskie
  ];

  home.file.".xprofile".text = ''
    # Start dbus if not running
    if ! pgrep -x dbus-daemon > /dev/null; then
      eval $(dbus-launch --exit-with-session)
    fi

    # Start spice agent for clipboard & dynamic resize
    ${pkgs.spice-vdagent}/bin/spice-vdagent &
  '';

  services = {
    # For auto mounting USB devices
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };
}
