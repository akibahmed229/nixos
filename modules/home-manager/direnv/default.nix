{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.direnv;
in {
  options.hm.direnv = {
    enable = mkEnableOption "Direnv configuration with Nix integration";

    silent = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to hide the 'direnv: loading...' messages in the shell.";
    };
  };

  config = mkIf cfg.enable {
    # programs.direnv.package handles the installation; manual home.packages is removed.
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true; # Faster nix-shell/flake loading

      enableZshIntegration = true;
      enableBashIntegration = true;

      config = {
        global = {
          # Suppress the "direnv: loading" spam if silent is enabled
          load_dotenv = true;
        };
      };

      stdlib = mkIf cfg.silent ''
        declare -g direnv_log_format=""
      '';
    };
  };
}
