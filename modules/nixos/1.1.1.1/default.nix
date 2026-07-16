# Configures the Wireshark network protocol analyzer.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm."1.1.1.1";
in {
  # --- 1. Define Options ---
  options.nm."1.1.1.1" = {
    en = mkEnableOption "Enable and configure the cloudflared-warp for Desktop.";

    package = mkOption {
      type = types.package;
      default = pkgs.cloudflare-warp;
      description = "The Nix package to use for cloudflared-warp.";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.en {
    services.cloudflare-warp = {
      enable = true;
      package = cfg.package;
    };
  };
}
