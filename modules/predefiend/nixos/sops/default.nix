# Secrets management with SOPS and Nix
{
  pkgs,
  inputs,
  user,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/var/lib/sops-nix/secret_file";
    age.generateKey = true;
  };
  # Secrets
  sops.secrets = {
    "akib/password/root_secret".neededForUsers = true; # decrypt the secret to /run/secrets-for-users
    "akib/password/my_secret".neededForUsers = true;
    "akib/wireguard/PrivateKey".neededForUsers = true;
  };

  environment.systemPackages = with pkgs; [
    sops
    age
  ];
}
