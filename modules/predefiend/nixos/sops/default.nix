/*
* useful resources: https://unmovedcentre.com/posts/secrets-management/#using-nix-secrets-with-nix-config
* Secrets management with SOPS and Nix
* System level secrets

* Create a age key
* mkdur -p ~/.config/sops/age
* age-keygen -o ~/.config/sops/age/keys.txt

* This will generateKey age key using ssh-to-age for each host key in sshKeyPaths
* nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'

* update changes .sops.yaml file like adding age key, removing old keys etc
* sops updatekeys secrets.yaml
*/
{
  pkgs,
  inputs,
  lib,
  user,
  ...
}: let
  secretsInput = builtins.toString inputs.secrets;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = lib.mkIf (user == "akib") "${secretsInput}/secrets/secrets.yaml";
    defaultSopsFormat = "yaml";
    age = {
      # this will use an age key that is expected to already be in the file-system
      keyFile = "/var/lib/sops-nix/keys.txt";

      # automatically import host SSH keys as age keys
      # sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      # Generate a new key if specified above file does not exist
      generateKey = true;
    };
  };

  /*
  * secrets will be outputs to /run/secrets
  * eg. /run/secrets/my_secret
  * secrets required for user creation are handled in respective ./users/<username>.nix files
  * because they will be out to /run/secrets-for-users and only when the user is assigned to a host.
  */

  # Secrets
  sops.secrets = lib.mkIf (user == "akib") {
    "akib/password/root_secret".neededForUsers = true; # decrypt the secret to /run/secrets-for-users
    "akib/password/my_secret".neededForUsers = true;
    "akib/wireguard/PrivateKey".neededForUsers = true;
    "akib/cloudflared".neededForUsers = true;
    "afif/password/my_secret".neededForUsers = true;
  };

  environment.systemPackages = with pkgs; [sops age];
}
