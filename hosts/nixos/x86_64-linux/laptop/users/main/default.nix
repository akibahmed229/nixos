{
  config,
  pkgs,
  ...
}: {
  /*
  ####################  NixOS provided default option ####################
  # Supported module options are `users.users.<name>.`
    - https://search.nixos.org/options?channel=25.05&query=users.users.%3Cname%3E.
  */

  # Username is inherited from the parent config
  inherit (config.nm.setUser) name;

  # Define user type
  isNormalUser = true;
  linger = true;

  # SSH or GPG keys (extend as needed)
  openssh.authorizedKeys.keys = [];

  # User groups for permissions
  extraGroups = [
    "networkmanager"
    "wheel"
    "systemd-journal"
    "docker"
    "kubernetes"
    "flatpak"
    "video"
    "audio"
    "render"
    "scanner"
    "disk"
    "input"
    "adbusers"
    "wireshark"
  ];

  # Default shell
  shell = pkgs.zsh;

  ####################  My custom module option will merge into default user ####################

  # Enable system + home-level configurations
  enSystemConf = true;
  enHomeConf = true;
}
