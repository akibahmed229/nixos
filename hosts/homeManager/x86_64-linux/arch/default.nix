/*
* This is an example configuration file for home-manager.
*
* The file is a Nix expression that evaluates to an attribute set. The
* attribute names are the names of options that home-manager understands.
*/
{
  pkgs,
  lib,
  user,
  inputs,
  config,
  ...
}: {
  hm = lib.mkMerge [
    {
      firefox = {
        enable = true;
        user = user;
      };
      nvim.enable = true;
      yazi.enable = true;
      atuin.enable = true;
      direnv.enable = true;
      fastfetch.enable = true;
      libinput.enable = true;
      pipewire.enable = true;
      wireplumber.enable = true;
      kitty.enable = true;
      espanso.enable = true;
      gemini-cli.enable = true;
    }

    (lib.mkIf (user == "akib") {
      git.enable = true;
      ssh.enable = true;
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    xdg-utils
    wl-clipboard
    tree
    hwinfo
    ripgrep

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Create XDG Dirs
  xdg = {
    enable = true;
    desktopEntries.image-roll = {
      name = "image-roll";
      exec = "${pkgs.image-roll}/bin/image-roll %F";
      mimeType = ["image/*"];
    };
    desktopEntries.gmail = {
      name = "Gmail";
      exec = ''xdg-open "https://mail.google.com/mail/?view=cm&fs=1&to=%u"'';
      mimeType = ["x-scheme-handler/mailto"];
    };
  };
}
