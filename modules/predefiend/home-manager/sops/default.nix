/*
* Secrets management with SOPS and Nix
* Home level secrets
*/
{
  inputs,
  user,
  ...
}: let
  secretsInput = builtins.toString inputs.mySsecrets;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    # This is the location of the host specific age-key for ta and will to have been extracted to this location via hosts/common/core/sops.nix on the host
    age.keyFile = "/home/${user}/.config/sops/age/keys.txt";

    defaultSopsFile = "${secretsInput}/secrets/secrets.yaml";
    validateSopsFiles = false;

    secrets = {
      "github/sshKey" = {
        path = "/home/${user}/.ssh/id_ed25519_github";
      };
      "gitlab/sshKey" = {
        path = "/home/${user}/.ssh/id_ed25519_gitlab";
      };
    };
  };
}
