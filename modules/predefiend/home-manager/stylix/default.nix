{
  pkgs,
  inputs,
  self,
  theme ? "gruvbox-dark-soft", # Default theme
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  imports = [inputs.stylix.homeManagerModules.stylix];

  stylix = {
    enable = true;
    base16Scheme = mkRelativeToRoot "public/themes/base16Scheme/${theme}.yaml";
    # Don't forget to apply wallpaper
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/akibahmed229/wallpaper/main/nixos.png";
      sha256 = "sha256-QcY0x7pE8pKQy3At81/OFl+3CUAbx0K99ZHk85QLSo0=";
    };

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
        package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
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
        desktop = 10;
        popups = 14;
      };
    };

    targets = {
      gtk.enable = true;
      gnome.enable = true;
      alacritty.enable = true;
      bat.enable = true;
      btop.enable = true;
      emacs.enable = true;
      spicetify.enable = false;
      firefox.enable = true;
      fzf.enable = true;
      hyprpaper.enable = true;
      kitty.enable = false;
      lazygit.enable = true;
      mangohud.enable = true;
      neovim.enable = true;
      neovim.transparentBackground.main = true;
      nixvim.enable = true;
      nixvim.transparentBackground.main = true;
      swaylock.enable = true;
      swaylock.useImage = true;
      sxiv.enable = true;
      tmux.enable = true;
      vesktop.enable = true;
      vim.enable = true;
      waybar.enable = true;
      wofi.enable = true;
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
