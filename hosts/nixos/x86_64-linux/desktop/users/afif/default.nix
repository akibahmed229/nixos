{
  config,
  mkRelativeToRoot,
  pkgs,
  system,
  ...
}: rec {
  name = "afif";
  isNormalUser = true;

  hashedPasswordFile =
    if config ? sops.secrets."${name}/password/my_secret"
    then config.sops.secrets."${name}/password/my_secret".path
    else null;

  openssh.authorizedKeys.keys = [];

  # Optional fallback password (hashed) if secret not used
  hashedPassword =
    if !(config ? sops.secrets."${name}/password/my_secret")
    then "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41"
    else null;

  extraGroups = [
    "networkmanager"
    "video"
    "audio"
  ];

  packages = with pkgs; [
    wget
    thunderbird
    vlc
  ];

  shell = pkgs.bash;

  # Minimal home configuration for afif
  homeFile = map mkRelativeToRoot [
    "home-manager/${system.desktopEnvironment}/home.nix"
  ];

  # Disable user/home-manager integration for afif
  enableSystemConf = false;
  enableHomeConf = false;
}
