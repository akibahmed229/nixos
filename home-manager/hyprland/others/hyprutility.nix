{pkgs, ...}:
{

  programs.waybar = {
    enable = true;
    settings = "${builtins.fromJSON ./waybar/config}";

    style = ''
      ${builtins.readFile ./waybar/style.css}
    '';
  };
  
  services.dunst = { 
    enable = true;
    configFile = "${builtins.readFile ./waybar/config}";
  };
}
