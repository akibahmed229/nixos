/*
* This is an example configuration file for home-manager.
*
* The file is a Nix expression that evaluates to an attribute set. The
* attribute names are the names of options that home-manager understands.
*/
{
  pkgs,
  self,
  lib,
  user,
  ...
}: let
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # imports from the predefiend modules folder
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms =
      [
        "stylix"
        "zsh"
        "tmux"
        "yazi"
        "atuin"
        "direnv"
        "fastfetch"
        "libinput"
        "pipewire/pipewire-pulse.conf.d"
        "pipewire/wireplumber.conf.d"
      ]
      ++ lib.optionals (user == "akib") [
        "git"
        "sops"
        "ssh"
      ];
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    xdg-utils
    wl-clipboard
    tree
    hwinfo
    ripgrep
    atuin
    direnv
    neovim

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
