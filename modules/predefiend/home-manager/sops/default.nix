/*
* Secrets management with SOPS and Nix
* Home level secrets
*/
{
  inputs,
  user,
  lib,
  config,
  ...
}: let
  inherit (config.home) homeDirectory;
  secretsInput = builtins.toString inputs.secrets;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = lib.mkIf (user == "akib") {
    # This is the location of the host specific age-key for akib and will to have been extracted to this location via hosts/common/core/sops.nix on the host
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = "${secretsInput}/secrets/home-manager.yaml";
    validateSopsFiles = false;

    secrets = {
      "github/sshKey" = {
        path = "${homeDirectory}/.ssh/id_ed25519_github";
      };
      "gitlab/sshKey" = {
        path = "${homeDirectory}/.ssh/id_ed25519_gitlab";
      };
    };
  };
}
