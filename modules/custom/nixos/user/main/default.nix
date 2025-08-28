{
  config,
  mkRelativeToRoot,
  pkgs,
  desktopEnvironment,
  hostname,
  userHome,
  ...
}: rec {
  inherit (config.setUser) name;
  isNormalUser = true;

  hashedPasswordFile =
    if config ? sops.secrets."${name}/password/my_secret"
    then config.sops.secrets."${name}/password/my_secret".path
    else null;

  keys = [];
  hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";
  extraGroups = ["networkmanager" "wheel" "docker" "video" "audio"];
  packages = with pkgs; [wget thunderbird vlc];
  shell = pkgs.zsh;

  homeFile =
    [{home = userHome name;}]
    ++ map mkRelativeToRoot [
      "home-manager/home.nix"
      "home-manager/${desktopEnvironment}/home.nix"
      "hosts/nixos/${hostname}/home.nix"
    ];
  enabledSystemConf = true;
  enabledHomeConf = true;
}
