{
  config,
  pkgs,
  ...
}: {
  name = "altair";
  isNormalUser = true;

  hashedPasswordFile =
    if config ? sops.secrets."generic/password/my_secret"
    then config.sops.secrets."generic/password/my_secret".path
    else null;

  # Optional fallback password (hashed) if secret not used
  hashedPassword =
    if !(config ? sops.secrets."generic/password/my_secret")
    then "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41"
    else null;

  shell = pkgs.bash;

  enableSystemConf = true;
  enableHomeConf = false;
}
