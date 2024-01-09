{ pkgs,
theme, ... }:

{
  xdg.configFile."wlogout/icons".source = ./wlogout/icons;
  xdg.configFile."wlogout".source = ./wlogout/noise.png;

  programs.waybar = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile "/home/akib/flake/home-manager/hyprland/others/waybar/config") ;
    style = builtins.readFile ./waybar/style.css;
  };
  
  services.dunst = { 
    enable = true;
    configFile = builtins.readFile ./dunst/dunstrc;
  };

  programs.wlogout = {
    enable = true;
    layout = builtins.fromJSON (builtins.readFile "/home/akib/flake/home-manager/hyprland/others/wlogout/layout");
    style =  builtins.readFile ./wlogout/style.css;
  };

  programs.swaylock = {
    enable = true;
    settings = builtins.readFile ./swaylock/config;
  };

  programs.wofi = {
    enable = true;
    settings = builtins.readFile ./wofi/config;
  };  

    home.file = {
    ".config/hypr" = {
      source = ./others/hyprpaper;
      recursive = true;
    };
    ".config//libinput" = {
      source = ./others/libinput;
      recursive = true;
    };
    ".config/swappy" = {
      source = ./others/swappy;
      recursive = true;
    };
    ".config/gtk-4.0" = {
      source = ../../themes/gtk/${theme};
      recursive = true;
    };
    ".config/gtk-3.0" = {
      source = ../../themes/gtk/${theme};
      recursive = true;
    };
  };
}
