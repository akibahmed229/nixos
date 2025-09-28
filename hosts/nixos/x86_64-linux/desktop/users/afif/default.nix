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
  hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";

  extraGroups = ["networkmanager" "video" "audio"];
  packages = with pkgs; [wget thunderbird vlc];
  shell = pkgs.bash;

  homeFile = map mkRelativeToRoot [
    "home-manager/${system.desktopEnvironment}/home.nix"
  ];
  enableSystemConf = false;
  enableHomeConf = false;
}
