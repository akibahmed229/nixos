{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.antigravity-cli;
in {
  options.hm.antigravity-cli = {
    en = mkEnableOption "Antigravity CLI configuration";

    model = mkOption {
      type = types.str;
      default = "gemini-3-flash";
      description = "The default model to use.";
    };

    editor = mkOption {
      type = types.str;
      default = "neovim";
      description = "Preferred editor for multi-line input or editing.";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional settings to merge into the antigravity-cli config.";
    };
  };

  config = mkIf cfg.en {
    programs.antigravity-cli = {
      enable = true;
      package = pkgs.antigravity-cli;

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
