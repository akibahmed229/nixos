{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.thunar;
in {
  options.hm.thunar = {
    enable = mkEnableOption "Thunar file manager configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      thunar
      xfce4-exo
      # Thumbnail support
      tumbler
      # Archive support
      kdePackages.ark
      # Plugins
      thunar-archive-plugin
      thunar-volman
    ];

    # Manage the Thunar config folder
    # We use xdg.configFile for standard pathing
    xdg.configFile."Thunar" = {
      source = ./config;
      recursive = true;
    };
  };
}
