{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.gemini-cli;
in {
  options.hm.gemini-cli = {
    enable = mkEnableOption "Gemini CLI configuration";

    model = mkOption {
      type = types.str;
      default = "gemini-3-flash";
      description = "The default Gemini model to use.";
    };

    editor = mkOption {
      type = types.str;
      default = "nvim";
      description = "Preferred editor for multi-line input or editing.";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional settings to merge into the gemini-cli config.";
    };
  };

  config = mkIf cfg.enable {
    programs.gemini-cli = {
      enable = true;
      package = pkgs.gemini-cli;

      # Using the option for model selection
      # Note: Adjust the attribute name if your specific version of gemini-cli
      # uses 'model' or 'defaultModel'
      # defaultModel = cfg.model;

      settings =
        recursiveUpdate {
          tools = {
            autoAccept = true;
            shell = {
              showColor = true;
            };
          };

          general = {
            previewFeatures = true;
            preferredEditor = cfg.editor;
            vimMode = true;
          };

          ui = {
            theme = "Default";
            showLineNumbers = true;
            useFullWidth = true;
          };

          security = {
            auth = {
              selectedType = "oauth-personal";
            };
          };
        }
        cfg.extraSettings;
    };
  };
}
