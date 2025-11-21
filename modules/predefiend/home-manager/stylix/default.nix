{
  pkgs,
  inputs,
  self,
  user,
  theme ? "gruvbox-dark-soft", # Default theme
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  imports = [inputs.stylix.homeModules.stylix];

  stylix = {
    enable = true;
    base16Scheme = mkRelativeToRoot "public/themes/base16Scheme/${theme}.yaml";
    # Don't forget to apply wallpaper
    # image = pkgs.fetchurl {
    #   url = "https://raw.githubusercontent.com/akibahmed229/wallpaper/main/gruv_saturn.png";
    #   sha256 = "sha256-AKSBdzNhqnHfQNqcjalXDrRV0qPidPrd7o+CV5tdQ98=";
    # };

    # example get cursor/scheme names
    /*
    $ nix build nixpkgs#bibata-cursors
    $ nix build nixpkgs#base16-schemes

    $ cd result

    $ nix run nixpkgs#eza -- --tree --level 3
    */

    # fonts and cursors
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 10;
        terminal = 11;
        desktop = 11;
        popups = 14;
      };
    };

    targets = {
      gtk.enable = true;
      qt.enable = true;
      gnome.enable = true;
      alacritty.enable = true;
      bat.enable = true;
      btop.enable = true;
      emacs.enable = true;
      spicetify.enable = false;
      firefox = {
        enable = true;
        profileNames = [user];
      };
      fzf.enable = true;
      # hyprpaper.enable = true;
      hyprland.enable = true;
      kitty.enable = true;
      lazygit.enable = true;
      mangohud.enable = true;
      neovim.enable = true;
      neovim.transparentBackground.main = true;
      nixvim.enable = true;
      nixvim.transparentBackground.main = true;
      swaylock.enable = true;
      swaylock.useWallpaper = true;
      sxiv.enable = true;
      tmux.enable = true;
      vesktop.enable = true;
      vim.enable = true;
      wofi.enable = true;
      yazi.enable = true;
    };

    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 1.0;
    };

    polarity = "dark"; # "light" or "either"
  };

  gtk = {
    iconTheme.package = pkgs.gruvbox-dark-icons-gtk;
    iconTheme.name = "oomox-gruvbox-dark";
  };
}
