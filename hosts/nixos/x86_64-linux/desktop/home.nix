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
        enable = true;
        user = user;
      };
      nvim.enable = true;
      quickshell.enable = true;
      spotify.enable = true;
      vencord.enable = true;
      swappy.enable = true;
      alacritty.enable = true;
      kitty.enable = true;
      thunar.enable = true;
      espanso.enable = false; # Buggy sometime
      gemini-cli.enable = true;
      hypridle.enable = true;
      emacs.enable = true;
    }

    (lib.mkIf (user == "akib") {
      openrgb.enable = true;
      ssh.enable = true;
      git.enable = true;
      sops = let
        secretsInput = toString inputs.secrets;
        homeDirectory = config.home.homeDirectory;
      in {
        enable = true;
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

  home.pointerCursor = lib.mkDefault {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    size = 24;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
  };

  services = {
    # For auto mounting USB devices
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };
}
