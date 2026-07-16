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
      firefox = {
        en = true;
        user = user;
      };
      nvim.en = true;
      quickshell.en = true;
      spotify.en = true;
      vencord.en = true;
      swappy.en = true;
      alacritty.en = true;
      kitty.en = true;
      thunar.en = true;
      espanso.en = false; # Buggy sometime
      gemini-cli.en = false;
      hypridle.en = true;
      emacs.en = true;
    }

    (lib.mkIf (user == "akib") {
      openrgb.en = true;
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
    # 2. Screenshot & Screen Tools
    self.packages.${pkgs.stdenv.hostPlatform.system}.screenshot # Screenshot tool.
    imagemagick # Image manipulation tool, often used for screenshots.

    # 4. Clipboard Management
    cliphist # Clipboard history management tool.
    wl-clipboard # Wayland clipboard tool.

    # 5. Utility
    udiskie
  ];

  services = {
    # For auto mounting USB devices
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };
}
