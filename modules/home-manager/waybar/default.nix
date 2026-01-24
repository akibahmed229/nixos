{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.waybar;
in {
  options.hm.waybar = {
    enable = mkEnableOption "Waybar status bar configuration";

    configPath = mkOption {
      type = types.path;
      default = ./config;
      description = "Path to the waybar JSON configuration file.";
    };

    stylePath = mkOption {
      type = types.path;
      default = ./style.css;
      description = "Path to the waybar CSS style file.";
    };
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;

      # We import the files directly.
      # Note: programs.waybar.settings expects an attrset or a list of attrsets.
      # If your 'config' file is raw JSON, we use builtins.fromJSON.
      settings = builtins.fromJSON (builtins.readFile cfg.configPath);
      style = builtins.readFile cfg.stylePath;

      # Systemd integration to ensure it starts with your compositor
      systemd.enable = true;
      systemd.target = "hyprland-session.target";
    };
  };
}
