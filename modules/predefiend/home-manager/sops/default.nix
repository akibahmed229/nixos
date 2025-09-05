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
      "github/username" = {
        path = "${homeDirectory}/.config/git/username";
      };
      "github/email" = {
        path = "${homeDirectory}/.config/git/email";
      };
    };

    # Render a tiny gitconfig snippet at activation time (no impurity at eval)
    templates."git-user.conf" = {
      content = ''
        [user]
          name = ${config.sops.placeholder."github/username"}
          email = ${config.sops.placeholder."github/email"}
          signingkey = ${config.sops.placeholder."github/email"}
      '';
      mode = "0400";
    };
  };
}
