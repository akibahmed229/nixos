{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.hm.stylix;

  # Default font configurations
  defaultFonts = {
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
  };
in {
  # --- 0. Imports ---
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  # --- 1. Define Options ---
  options.hm.stylix = {
    enable = mkEnableOption "Stylix theming for Home Manager";

    themeScheme = mkOption {
      type = types.path;
      default = null;
      description = "Path to the Base16 theme scheme yaml file.";
    };

    # Cursor Configuration
    cursor = {
      package = mkOption {
        type = types.package;
        default = pkgs.bibata-cursors;
        description = "Package providing the cursor theme.";
      };
      name = mkOption {
        type = types.str;
        default = "Bibata-Modern-Classic";
        description = "Name of the cursor theme.";
      };
      size = mkOption {
        type = types.int;
        default = 24;
        description = "Size of the cursor.";
      };
    };

    # Font Configuration
    fonts = mkOption {
      type = types.attrsOf types.unspecified;
      default =
        defaultFonts
        // {
          sizes = {
            applications = 10;
            terminal = 11;
            desktop = 11;
            popups = 14;
          };
        };
      description = "Configuration for fonts and their sizes.";
    };

    # Integration Targets
    targets = mkOption {
      type = types.attrsOf types.unspecified;
      default = {
        gtk.enable = true;
        qt.enable = true;
        gnome.enable = true;
        alacritty.enable = true;
        bat.enable = true;
        btop.enable = true;
        emacs.enable = true;
        spicetify.enable = false; # Often conflicts with custom themes
        firefox = {
          enable = true;
          profileNames = [config.home.username]; # Auto-detect user
        };
        fzf.enable = true;
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
      description = "Enable/disable specific Stylix targets.";
    };

    # Icon Theme (Home Manager specific extra)
    iconTheme = {
      package = mkOption {
        type = types.package;
        default = pkgs.gruvbox-dark-icons-gtk;
        description = "Package for the GTK icon theme.";
      };
      name = mkOption {
        type = types.str;
        default = "oomox-gruvbox-dark";
        description = "Name of the icon theme to apply to GTK.";
      };
    };

    polarity = mkOption {
      type = types.enum ["light" "dark" "either"];
      default = "dark";
      description = "Color polarity preference.";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = cfg.themeScheme;

      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/akibahmed229/wallpaper/main/gruv_saturn.png";
        sha256 = "sha256-AKSBdzNhqnHfQNqcjalXDrRV0qPidPrd7o+CV5tdQ98=";
      };

      cursor = {
        package = cfg.cursor.package;
        name = cfg.cursor.name;
        size = cfg.cursor.size;
      };

      fonts = cfg.fonts;
      targets = cfg.targets;

      opacity = {
        applications = 1.0;
        terminal = 1.0;
        desktop = 1.0;
        popups = 1.0;
      };

      polarity = cfg.polarity;
    };

    # Apply the separate GTK Icon Theme settings
    gtk = {
      enable = true;
      iconTheme = {
        package = cfg.iconTheme.package;
        name = cfg.iconTheme.name;
      };
    };
  };
}
