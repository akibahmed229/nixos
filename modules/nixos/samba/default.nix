# Configures Samba file sharing, automatically generating shares based on a list of defined drives.
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nm.samba;

  generateShares = listToAttrs (map (drive: {
      name = drive.device;
      value = {
        path = drive.mountPoint;
        comment = "Shared Drive: ${drive.device}";

        # Shares MUST be browseable for logged-in users to see them
        browseable = "yes";

        "read only" = boolToYesNo cfg.readOnly;
        "guest ok" = boolToYesNo cfg.guestOk;
        "create mask" = cfg.createMask;
        "directory mask" = cfg.directoryMask;
        "valid users" = cfg.validUsers;
        "invalid users" = cfg.invalidUsers;
      };
    })
    cfg.shares);

  boolToYesNo = b:
    if b
    then "yes"
    else "no";
in {
  options.nm.samba = {
    en = mkEnableOption "Enable Samba file sharing.";

    shares = mkOption {
      type = types.listOf (types.submodule ({config, ...}: {
        options = {
          device = mkOption {
            type = types.str;
            description = "The device identifier (e.g., 'sda1').";
          };
          mountPoint = mkOption {
            type = types.str;
            default = "/mnt/${config.device}";
            description = "The absolute path to the mount point.";
          };
        };
      }));
      default = [];
      description = "List of drives to automatically configure as Samba shares.";
    };

    guestOk = mkOption {
      type = types.bool;
      default = false;
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

    validUsers = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Space-separated list of valid users.";
    };

    invalidUsers = mkOption {
      type = types.str;
      default = "guest";
      description = "Space-separated list of invalid users.";
    };
  };

  config = mkIf cfg.en {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings =
        # Inject global setting so Samba handles credentials strictly
        {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "NixOS Samba Server";
            "netbios name" = "nixos-desktop";
            "security" = "user";
            "map to guest" = "Bad User";
          };
        }
        // generateShares;
    };
  };
}
