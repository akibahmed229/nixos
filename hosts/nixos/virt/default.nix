/*
* Host-specific configuration for NixOS systems.
* This is your system's configuration file.
* Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
*/
{
  self,
  pkgs,
  user,
  lib,
  state-version,
  system,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  imports =
    [(mkRelativeToRoot "home-manager/dwm")]
    ++ mkImport {
      path = mkRelativeToRoot "modules/predefiend/nixos";
      ListOfPrograms =
        [
          "stylix"
          "impermanence"
          "dbus"
        ]
        ++ lib.optionals (user == "akib") [
          "sops"
          "intel-gpu"
        ];
    };

  # Custom nixos modules for
  # User management configuration ( custom module ) - see modules/custom/nixos/user
  setUser = {
    name = "${user}";
    usersPath = ./users/.;
    nixosUsers.enable = true;
    homeUsers.enable = true;

    system = {
      desktopEnvironment = "dwm";
      inherit state-version;
      inherit (system) path name;
    };
  };

  users.defaultUserShell = pkgs.zsh;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      spice-vdagent
      guestfs-tools
      cryptsetup
      wget
      direnv
      fastfetch
    ];
    shells = [pkgs.zsh];
    pathsToLink = ["/share/zsh" "/tmp" "/home/${user}"];
  };

  programs = {
    zsh = {
      enable = true;
      shellInit = ''
        #xcompmgr &
        #picom &
      '';
      ohMyZsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "terraform"
          "systemadmin"
          "vi-mode"
        ];
        theme = "agnoster";
      };
    };
  };

  # Enables copy / paste when running in a KVM with spice.
  services = {
    spice-vdagentd.enable = true;
    qemuGuest.enable = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
