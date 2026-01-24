{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.fastfetch;
in {
  options.hm.fastfetch = {
    enable = mkEnableOption "Fastfetch system information tool configuration";

    configPath = mkOption {
      type = types.path;
      # Default to the local config folder within the module directory
      default = ./config;
      description = "Path to the fastfetch configuration directory.";
    };
  };

  config = mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
      package = pkgs.fastfetch;
    };

    # Link the configuration directory using XDG standards
    xdg.configFile."fastfetch" = {
      source = cfg.configPath;
      recursive = true;
    };
  };
}
