{ pkgs
, inputs
, lib
, config
, ...
}:

{
  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix.base16Scheme = ../../../../public/themes/base16Scheme/gruvbox-dark-soft.yaml;
  # Don't forget to apply wallpaper
  stylix.image = ../../../../public/wallpaper/nixos.png;

  # example get cursor/scheme names
  /*
    $ nix build nixpkgs#bibata-cursors
    $ nix build nixpkgs#base16-schemes
    
    $ cd result
    
    $ nix run nixpkgs#eza -- --tree --level 3
  */

  # fonts and cursors
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Ice";

  stylix.fonts = {
    monospace = {
      package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
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
  };

  stylix.fonts.sizes = {
    applications = 12;
    terminal = 15;
    desktop = 10;
    popups = 10;
  };

  stylix.opacity = {
    applications = 1.0;
    terminal = 1.0;
    desktop = 1.0;
    popups = 1.0;
  };

  stylix.polarity = "dark"; # "light" or "either"
}
