# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, inputs, state-version, ... }:

{
  imports =
    [ (import ./hardware-configuration.nix) ] ++
    [ (import ../../home-manager/dwm/default.nix) ] ++
    map
      (myprograms:
        let
          path = name:
            if name == "disko" then
              (import ../../modules/predefiend/nixos/${name} { device = "/dev/vda"; }) # diskos module with device name (e.g., /dev/sda1)
            else
              (import ../../modules/predefiend/nixos/${name}); # path to the module
        in
        path myprograms # loop through the myprograms and import the module
      )
      # list of programs
      [ "impermanence" "disko" "sops" ];

  users.defaultUserShell = pkgs.zsh;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      #  wget
    ];
    shells = [ pkgs.zsh ];
    pathsToLink = [ "/share/zsh" "/tmp" "/home/akib" ];
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "${state-version}"; # Did you read the comment?
}
