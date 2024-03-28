{ pkgs
, theme
, ...
}:

{
  xdg.configFile."wlogout/icons".source = ./wlogout/icons;
  xdg.configFile."wlogout".source = ./wlogout/noise.png;

  programs = {
    waybar = {
      enable = true;
    };
    wlogout = {
      enable = true;
      layout = builtins.fromJSON ''${builtins.readFile ./wlogout/layout}'';
      style = builtins.readFile ./wlogout/style.css;
    };
    swaylock = {
      enable = true;
      settings = builtins.readFile ./swaylock/config;
    };
    wofi = {
      enable = true;
      settings = builtins.readFile ./wofi/config;
    };
  };

  services.dunst = {
    enable = true;
    configFile = builtins.readFile ./dunst/dunstrc;
  };

  home.file = {
    ".config/hypr" = {
      source = ./hyprpaper;
      recursive = true;
    };
    ".config/waybar" = {
      source = ./waybar;
      recursive = true;
    };
    ".config//libinput" = {
      source = ./libinput;
      recursive = true;
    };
    ".config/swappy" = {
      source = ./swappy;
      recursive = true;
    };
    ".config/gtk-4.0" = {
      source = ../../../themes/gtk/${theme};
      recursive = true;
    };
    ".config/gtk-3.0" = {
      source = ../../../themes/gtk/${theme};
      recursive = true;
    };
  };
}
