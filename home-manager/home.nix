{ config, pkgs, user, state-version, ... }:

{
  imports =   
  # [(import ./kde/home.nix)]; # uncomment to use KDE Plasma 
    [(import ./gnome/home.nix)]++ # uncomment to use GNOME  
    [(import ../programs/firefox/firefox.nix)]++
    [(import ../programs/lf/lf.nix)];


# Home Manager needs a bit of information about you and the paths it should
# manage.
  home.username = "${user}";
  home.homeDirectory = "/home/${user}"; 

# This value determines the Home Manager release that your configuration is
# compatible with. This helps avoid breakage when a new Home Manager release
# introduces backwards incompatible changes.
#
# You should not change this value, even if you update Home Manager. If you do
# want to update the value, then make sure to first check the Home Manager
# release notes.
  home.stateVersion = "${state-version}"; # Please read the comment before changing.

# The home.packages option allows you to install Nix packages into your
# environment.
    home.packages = with pkgs; [
      tree
      bibata-cursors
      adw-gtk3
      gruvbox-dark-gtk
      gruvbox-dark-icons-gtk

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

# Home Manager is pretty good at managing dotfiles. The primary way to manage
# plain files is through 'home.file'.
  home.file = {
# # Building this configuration will create a copy of 'dotfiles/screenrc' in
# # the Nix store. Activating the configuration will then make '~/.screenrc' a
# # symlink to the Nix store copy.
# ".screenrc".source = dotfiles/screenrc;

# # You can also set the file content immediately.
# ".gradle/gradle.properties".text = ''
#   org.gradle.console=verbose
#   org.gradle.daemon.idletimeout=3600000
# '';

    ".config/alacritty" = {
      source = ../programs/alacritty;
      recursive = true;
    };

    ".config/OpenRGB" = {
      source = ../programs/OpenRGB;
      recursive = true;
    };
  
    ".ssh" = {
      source = ../programs/ssh;
      recursive = true;
    };
  };

  gtk = {
    enable = true;
    cursorTheme.name = "Bibata-Modern-Classic";
    cursorTheme.package =  pkgs.bibata-cursors;
    theme.package = pkgs.adw-gtk3;
    theme.name = "adw-gtk3-dark";
    iconTheme.package = pkgs.gruvbox-dark-icons-gtk;
    iconTheme.name = "oomox-gruvbox-dark";
  };

  home = {
    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      size = 38;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };

# You can also manage environment variables but you will have to manually
# source
#
#  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
#
# or
#
#  /etc/profiles/per-user/akib/etc/profile.d/hm-session-vars.sh
#
# if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
   EDITOR = "nvim";
  };

# Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

# Tmux Config
  programs.tmux ={
    enable = true;
   # secureSocket = false;
    plugins = with pkgs; [
      tmuxPlugins.sensible
        tmuxPlugins.catppuccin
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.yank
        tmuxPlugins.tmux-fzf
        tmuxPlugins.resurrect
        tmuxPlugins.continuum
    ];
    extraConfig = ''	
      source /home/${user}/flake/programs/tmux/tmux.conf
      '';
  };

# NeoVim configuration
 #programs.neovim = {
 # enable = true;
 # defaultEditor = true;
 # vimAlias = true;
 # viAlias = true;
 # #coc = {
 # #  enable = true;
 # #};
## configure = {
## customRC = '' 
## luafile ${./nvim/init.lua}
## '';
##  };
 #};

}
