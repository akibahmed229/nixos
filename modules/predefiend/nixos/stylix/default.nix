{
  pkgs,
  inputs,
  self,
  theme ? "gruvbox-dark-soft", # The default theme
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  imports = [inputs.stylix.nixosModules.stylix];

  stylix = {
    enable = true;
    base16Scheme = mkRelativeToRoot "public/themes/base16Scheme/${theme}.yaml";
    # Don't forget to apply wallpaper
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/akibahmed229/wallpaper/main/nixos.png";
      sha256 = "sha256-QcY0x7pE8pKQy3At81/OFl+3CUAbx0K99ZHk85QLSo0=";
    };

    homeManagerIntegration.autoImport = false;
    homeManagerIntegration.followSystem = false;

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
        desktop = 10;
        popups = 14;
      };
    };

    targets = {
      # Enable the following to use the gtk theme
      gtk.enable = true;
      gnome.enable = true;
      # Grub theme
      grub.enable = true;
      grub.useImage = true;

      console.enable = true;
      nixvim = {
        enable = true;
        transparentBackground.main = true;
      };
    };

    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 1.0;
    };

    polarity = "dark"; # "light" or "either"
  };
}
