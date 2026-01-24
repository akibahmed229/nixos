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
  home.packages = with pkgs; [
    # 2. Screenshot & Screen Tools
    self.packages.${pkgs.stdenv.hostPlatform.system}.wallpaper
    self.packages.${pkgs.stdenv.hostPlatform.system}.screenshot # Screenshot tool.
    imagemagick # Image manipulation tool, often used for screenshots.
    self.packages.${pkgs.stdenv.hostPlatform.system}.custom_nsxiv # Image viewer.

    # 4. Clipboard Management
    cliphist # Clipboard history management tool.
    wl-clipboard # Wayland clipboard tool.

    # 5. Utility
    udiskie
  ];

  hm = lib.mkMerge [
    {
      firefox = {
        enable = true;
        user = user;
      };
      nvim.enable = true;
      ssh.enable = true;
      quickshell.enable = true;
      spotify.enable = true;
      vencord.enable = true;
      wofi.enable = true;
      swappy.enable = true;
      alacritty.enable = true;
      kitty.enable = true;
      thunar.enable = true;
      espanso.enable = true;
      gemini-cli.enable = true;
      hypridle.enable = true;
      emacs.enable = true;
    }

    (lib.mkIf (user == "akib") {
      openrgb.enable = true;
      git.enable = true;
      sops = let
        secretsInput = toString inputs.secrets;
        homeDirectory = config.home.homeDirectory;
      in {
        enable = true;
        defaultSopsFile = "${secretsInput}/secrets/home-manager.yaml";

        # Define your secrets
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

  services = {
    # For auto mounting USB devices
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };
}
