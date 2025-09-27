{
  config,
  mkRelativeToRoot,
  pkgs,
  system,
  ...
}: rec {
  # Username is inherited from the parent config
  inherit (config.setUser) name;

  # Define user type
  isNormalUser = true;

  # Password handling (prefer sops secret, fallback to null)
  hashedPasswordFile =
    if config ? sops.secrets."${name}/password/my_secret"
    then config.sops.secrets."${name}/password/my_secret".path
    else null;

  # Optional fallback password (hashed) if secret not used
  hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";

  # SSH or GPG keys (extend as needed)
  openssh.authorizedKeys.keys = [];

  # User groups for permissions
  extraGroups = [
    "networkmanager"
    "wheel"
    "docker"
    "video"
    "audio"
  ];

  # Default packages for the user
  packages = with pkgs; [
    wget
    thunderbird
    vlc
  ];

  # Default shell
  shell = pkgs.zsh;

  # Home Manager configurations
  homeFile = map mkRelativeToRoot [
    "home-manager/${system.desktopEnvironment}/home.nix"
  ];

  # Enable system + home-level configurations
  enableSystemConf = true;
  enableHomeConf = true;
}
