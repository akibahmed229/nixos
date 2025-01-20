/*
* Host-specific configuration for NixOS systems.
* This is your system's configuration file.
* Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
*/
{
  self,
  pkgs,
  user,
  state-version,
  hostname,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  imports =
    [
      (import ../../../modules/predefiend/nixos/disko {device = "/dev/vda";})
      (mkRelativeToRoot "home-manager/dwm")
    ]
    ++ mkImport {
      path = mkRelativeToRoot "modules/predefiend/nixos";
      ListOfPrograms = ["impermanence" "sops"];
    };

  # Custom nixos modules for
  setUser = {
    name = "${user}";
    inherit hostname state-version;
    desktopEnvironment = "dwm";
    users.enable = true;
    homeUsers.enable = true;
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
      git
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
