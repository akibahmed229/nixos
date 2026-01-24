{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.hm.sops;
in {
  # --- 0. Imports ---
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  # --- 1. Define Options ---
  options.hm.sops = {
    enable = mkEnableOption "Sops secrets management for Home Manager";

    defaultSopsFile = mkOption {
      type = types.path;
      default = null;
      description = "Path to the default secrets file (e.g. from inputs.secrets).";
    };

    age = {
      keyFile = mkOption {
        type = types.str;
        # Standard user-level location for age keys
        default = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        description = "Path to the user's age key file.";
      };

      generateKey = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to generate the age key if missing (usually handled manually for users).";
      };
    };

    secrets = mkOption {
      type = types.attrsOf types.unspecified;
      default = {};
      description = "Attribute set of secrets to define in sops.secrets.";
    };

    # Added specifically for your Git config use-case
    templates = mkOption {
      type = types.attrsOf types.unspecified;
      default = {};
      description = "Attribute set of templates to define in sops.templates.";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # Install necessary tools for managing secrets
    home.packages = with pkgs; [sops age];

    sops = {
      defaultSopsFile = cfg.defaultSopsFile;
      validateSopsFiles = false; # Often required in HM to avoid build-time checks failing without keys

      age = {
        keyFile = cfg.age.keyFile;
        generateKey = cfg.age.generateKey;
      };

      # Merge the secrets passed via options
      secrets = cfg.secrets;

      # Merge the templates passed via options
      templates = cfg.templates;
    };
  };
}
