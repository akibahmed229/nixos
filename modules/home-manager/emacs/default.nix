{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.emacs;
in {
  options.hm.emacs = {
    enable = mkEnableOption "Emacs configuration and service";

    package = mkOption {
      type = types.package;
      default = pkgs.emacs-gtk;
      description = "The Emacs package to use (e.g., emacs-gtk, emacs-pgtk, or doom-emacs).";
    };

    runService = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to run Emacs as a background daemon service.";
    };
  };

  config = mkIf cfg.enable {
    # Install the package
    home.packages = [cfg.package];

    # Manage the Emacs config directory
    # Points to the 'config' folder in the same directory as this nix file
    xdg.configFile."emacs" = {
      source = ./config;
      recursive = true;
    };

    # Background Daemon Service
    services.emacs = {
      enable = cfg.runService;
      package = cfg.package;
      # Ensures the service starts with the correct environment
      client.enable = true;
    };
  };
}
