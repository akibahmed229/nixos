# Configures Samba file sharing, automatically generating shares based on a list of defined drives.
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nm.samba;

  # Function to generate the required services.samba.settings format
  generateShares = listToAttrs (map (drive: {
      # The Samba share name is derived from the device name
      name = drive.device;
      value = {
        # The share path is the drive's mount point
        path = drive.mountPoint;
        comment = "Shared Drive: ${drive.device}";
        browseable = boolToYesNo cfg.guestOk; # Use the module default
        "read only" = boolToYesNo cfg.readOnly; # Use the module default
        "guest ok" = boolToYesNo cfg.guestOk; # Use the module default
        "create mask" = cfg.createMask;
        "directory mask" = cfg.directoryMask;
      };
    })
    cfg.shares);

  # Helper to convert Nix boolean to Samba's required "yes"/"no" string
  boolToYesNo = b:
    if b
    then "yes"
    else "no";
in {
  # --- 1. Define Options ---
  options.nm.samba = {
    enable = mkEnableOption "Enable Samba file sharing.";

    shares = mkOption {
      type = types.listOf (types.submodule ({config, ...}: {
        # Added 'config' here
        options = {
          device = mkOption {
            type = types.str;
            description = "The device identifier (e.g., 'sda1') used as the share name and comment.";
          };
          mountPoint = mkOption {
            type = types.str;
            # Dynamic default based on the device name
            default = "/mnt/${config.device}";
            description = "The absolute path to the mount point (e.g., '/mnt/sda1').";
          };
        };
      }));
      default = [];
      description = "List of drives to automatically configure as Samba shares.";
    };

    guestOk = mkOption {
      type = types.bool;
      default = true;
      description = "Allow guest access to the shares.";
    };

    readOnly = mkOption {
      type = types.bool;
      default = false;
      description = "Set shares to be read-only by default.";
    };

    createMask = mkOption {
      type = types.str;
      default = "0644";
      description = "File creation mask (permissions).";
    };

    directoryMask = mkOption {
      type = types.str;
      default = "0755";
      description = "Directory creation mask (permissions).";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    services.samba = {
      # Dont forget to set a password for the user with smbpasswd -a ${user}
      enable = true;
      settings = generateShares;
      # Automatically open firewall for Samba traffic
      openFirewall = true;
    };
  };
}
