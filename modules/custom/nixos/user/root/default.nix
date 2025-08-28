{
  config,
  pkgs,
  userHome,
  ...
}: rec {
  name = "root";
  isNormalUser = false;

  hashedPasswordFile =
    if (config.setUser.name == "akib")
    then config.sops.secrets."akib/password/root_secret".path
    else null;

  keys = [];
  hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41";
  packages = with pkgs; [neovim wget];
  extraGroups = [];
  shell = pkgs.bash;

  homeFile = [{home = userHome name;}];
  enabledSystemConf = false;
  enabledHomeConf = false;
}
