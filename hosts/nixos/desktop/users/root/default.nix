# Root user configuration
{
  config,
  pkgs,
  ...
}: rec {
  name = "root"; # Root account
  isNormalUser = false; # System/root account, not a normal user

  # Use a sops-managed secret for the root password if user is "akib"
  hashedPasswordFile =
    if config.setUser.name == "akib"
    then config.sops.secrets."akib/password/root_secret".path
    else null;

  keys = []; # No SSH keys configured
  hashedPassword = "$6$udP2KZ8FM5LtH3od$m61..P7kY3ckU55LhG1oR8KgsqOj7T9uS1v4LUChRAn1tu/fkRa2fZskKVBN4iiKqJE5IwsUlUQewy1jur8z41"; # Fallback password

  packages = with pkgs; [
    # Packages available for root
    neovim
    wget
  ];

  extraGroups = []; # Root doesn't need extra groups
  shell = pkgs.bash; # Default shell for root

  # Minimal home configuration for root
  homeFile = [];

  # Disable user/home-manager integration for root
  enableSystemConf = false;
  enableHomeConf = false;
}
