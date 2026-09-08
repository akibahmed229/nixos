{
  pkgs,
  self,
  lib,
  user,
  inputs,
  config,
  ...
}: let
in {
  hm = lib.mkMerge [
    {
      nvim.en = true;
    }

    (lib.mkIf (user == "akib") {
      ssh.en = true;
      git.en = true;
      sops = let
        secretsInput = toString inputs.secrets;
        homeDirectory = config.home.homeDirectory;
      in {
        en = true;
        defaultSopsFile = "${secretsInput}/secrets/home-manager.yaml";
        secrets = {
          "github/sshKey".path = "${homeDirectory}/.ssh/id_ed25519_github";
          "gitlab/sshKey".path = "${homeDirectory}/.ssh/id_ed25519_gitlab";
          "github/username".path = "${homeDirectory}/.config/git/username";
          "github/email".path = "${homeDirectory}/.config/git/email";
        };
        # The dynamic Git template
        templates = {
          "git-user.conf" = {
            mode = "0400";
            content = ''
              [user]
                name = ${config.sops.placeholder."github/username"}
                email = ${config.sops.placeholder."github/email"}
                signingkey = ${config.sops.placeholder."github/email"}
            '';
          };
        };
      };
    })
  ];

  home.packages = with pkgs; [
    # 4. Clipboard Management
    cliphist # Clipboard history management tool.
    wl-clipboard # Wayland clipboard tool.
  ];
}
