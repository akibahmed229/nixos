# Configures OpenRazer and Polychromatic for Razer peripheral control.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.openrazer;
in {
  # --- 1. Define Options ---
  options.nm.openrazer = {
    enable = mkEnableOption "Enable OpenRazer support for Razer devices.";

    enablePolychromatic = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Polychromatic, the graphical interface for OpenRazer.";
    };

    users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of usernames to add to the 'openrazer' group to allow daemon access.";
      example = ["alice" "bob"];
    };
  };

  /*
    * In order to run the openrazer-daemon service, your user needs to be part of the openrazer group.

        hardware.openrazer.users = ["<name>?"];


  # some other tools for keyboard and mouse control

  * CORSAIR USERS
      https://github.com/ckb-next/ckb-next/wiki/Supported-Hardware

  * SOLAAR/LOGITECH
      https://github.com/pwr-Solaar/Solaar
      https://flathub.org/apps/io.github.pwr_solaar.solaar

  * OPENRAZER & POLYCHROMATIC & RAZERGENIE
      https://openrazer.github.io/
      https://polychromatic.app/
      https://github.com/z3ntu/RazerGenie

  * ERUPTION
      https://github.com/eruption-project/eruption

  * PIPER/STEELSERIES/LOGITECH/ASUS/GLORIOUS
      https://github.com/libratbag/piper?tab=readme-ov-file
      https://github.com/libratbag/libratbag/tree/master/data/devices
      https://flathub.org/apps/org.freedesktop.Piper


  * you can check your mouse pooling rate with

      sudo nix-shell -p evhz.out --run 'evhz ...'
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 1. Enable OpenRazer hardware service
    hardware.openrazer.enable = true;

    # 2. Add specified users to the openrazer group (required for service access)
    hardware.openrazer.users = cfg.users;

    # 3. Enable Polychromatic GUI (optional)
    environment.systemPackages = mkIf cfg.enablePolychromatic [
      pkgs.polychromatic
    ];
  };
}
