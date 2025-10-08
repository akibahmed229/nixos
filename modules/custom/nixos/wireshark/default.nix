# Configures the Wireshark network protocol analyzer.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.wireshark;
in {
  # --- 1. Define Options ---
  options.nm.wireshark = {
    enable = mkEnableOption "Enable and configure the Wireshark network protocol analyzer.";

    package = mkOption {
      type = types.package;
      default = pkgs.wireshark;
      description = "The Nix package to use for Wireshark.";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    /*
    Wireshark is a free, open-source network protocol analyzer that captures and displays network traffic in real-time.
    By enabling this, the system installs the program and configures necessary user groups for packet capture.
    */
    programs = {
      wireshark = {
        enable = true;
        package = cfg.package;
      };
    };
  };
}
