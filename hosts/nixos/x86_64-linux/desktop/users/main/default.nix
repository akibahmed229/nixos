{
  config,
  mkRelativeToRoot,
  pkgs,
  system,
  ...
}: rec {
  /*
  ####################  NixOS provided default option ####################
  # Supported module options are `users.users.<name>.`
    - https://search.nixos.org/options?channel=25.05&query=users.users.%3Cname%3E.
  */

  # Username is inherited from the parent config
  inherit (config.nm.setUser) name;

  # Define user type
  isNormalUser = true;

  # Password handling (prefer sops secret, fallback to null)
  # Create a Hased Pass whith `nix run nixpkgs#mkpasswd -- -m SHA-512 -s`
  hashedPasswordFile =
    if config ? sops.secrets."${name}/password/my_secret"
    then config.sops.secrets."${name}/password/my_secret".path
    else null;

  # Optional fallback password (hashed) if secret not used
  hashedPassword =
    if !(config ? sops.secrets."${name}/password/my_secret")
    then "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41"
    else null;

  # SSH or GPG keys (extend as needed)
  openssh.authorizedKeys.keys = [];

  # User groups for permissions
  extraGroups = [
    "networkmanager"
    "wheel"
    "systemd-journal"
    # "docker"
    "kubernetes"
    "flatpak"
    "video"
    "audio"
    "scanner"
    "libvirtd"
    "kvm"
    "disk"
    "input"
    "adbusers"
    "wireshark"
    "openrazer"
  ];

  # Default packages for the user
  packages = with pkgs; [
    wget
    thunderbird
    vlc
  ];

  # Default shell
  shell = pkgs.zsh;

  ####################  My custom module option will merge into default user ####################

  # Home Manager configurations
  homeFile = map mkRelativeToRoot [
    "home-manager/${system.desktopEnvironment}/home.nix"
  ];

  # Enable system + home-level configurations
  enableSystemConf = true;
  enableHomeConf = true;
}
