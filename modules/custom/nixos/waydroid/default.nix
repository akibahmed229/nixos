# Configures the Waydroid virtualisation service for running Android apps.
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nm.waydroid;
in {
  # --- 1. Define Options ---
  options.nm.waydroid = {
    enable = mkEnableOption "Enable and configure the Waydroid service for running Android applications.";
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    /*
    Waydroid is an open-source software project that allows you to run Android applications on Linux systems
    by booting a full Android environment within a containerized environment using Linux namespaces.
    */
    virtualisation.waydroid.enable = true;
  };
}
