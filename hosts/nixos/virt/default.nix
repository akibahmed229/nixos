# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  self,
  pkgs,
  unstable,
  inputs,
  user,
  ...
}: {
  imports =
    [
      (import ./hardware-configuration.nix)
      (import ../../../modules/predefiend/nixos/disko {device = "/dev/vda";})
      (self.lib.mkRelativeToRoot "home-manager/dwm")
    ]
    ++ self.lib.mkImport {
      path = ../../../modules/predefiend/nixos;
      ListOfPrograms = ["impermanence" "sops"];
    };

  users.defaultUserShell = pkgs.zsh;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      #  wget
    ];
    shells = [pkgs.zsh];
    pathsToLink = ["/share/zsh" "/tmp" "/home/akib"];
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

    command-not-found.dbPath = inputs.programsdb.packages.${pkgs.system}.programs-sqlite;
    command-not-found.enable = false;
  };

  # Enables copy / paste when running in a KVM with spice.
  services.spice-vdagentd.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Home manager configuration as a module
  home-manager = {
    users.${user} = {
      imports = [(self.lib.mkRelativeToRoot "home-manager/home.nix")];
    };
  };
}
