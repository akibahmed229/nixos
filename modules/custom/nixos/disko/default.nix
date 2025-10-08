# This module provides a declarative way to configure disk partitioning
# and formatting using disko, based on a common GPT + LVM + BTRFS layout.
{
  config,
  lib,
  ...
}: let
  cfg = config.nm.disko;

  # A submodule to define the options for each BTRFS subvolume.
  subvolumeModule = {name, ...}: {
    options = with lib; {
      mountpoint = mkOption {
        type = types.str;
        # Default the mountpoint to the subvolume name, except for the root.
        default =
          if name == "/root"
          then "/"
          else name;
        description = "The mount point for this subvolume.";
      };
      mountOptions = mkOption {
        type = types.listOf types.str;
        # The root subvolume doesn't need a `subvol=` option, but others do.
        default =
          if name == "/root"
          then []
          else ["subvol=${lib.strings.removePrefix "/" name}" "noatime"];
        defaultText =
          if name == "/root"
          then "[]"
          else ''[ "subvol=..." "noatime" ]'';
        description = "A list of mount options for the subvolume.";
      };
    };
  };
in {
  options.nm.disko = with lib; {
    enable = mkEnableOption "disko declarative disk configuration";

    device = mkOption {
      type = types.str;
      example = "/dev/vda";
      description = "The block device to partition, e.g., /dev/sda or /dev/nvme0n1. This must be set.";
    };

    espSize = mkOption {
      type = types.str;
      default = "500M";
      description = "Size of the EFI System Partition (ESP).";
    };

    swapSize = mkOption {
      type = types.str;
      default = "4G";
      description = "Size of the swap partition.";
    };

    btrfsSubvolumes = mkOption {
      type = types.attrsOf (types.submodule subvolumeModule);
      default = {
        "/root" = {mountpoint = "/";};
        "/persist" = {mountpoint = "/persist";};
        "/nix" = {mountpoint = "/nix";};
      };
      description = "Attribute set of BTRFS subvolumes to create.";
      example = literalExpression ''
        {
          "/root" = { mountpoint = "/"; };
          "/nix" = { mountpoint = "/nix"; mountOptions = [ "compress=zstd" "noatime" "subvol=nix" ]; };
          "/home" = { mountpoint = "/home"; };
        }
      '';
    };
  };

  /*
  # Example Usage
    ```nix
     # Configure your disk layout using the new module
      nm.disko = {
        enable = true;
        # This is the only mandatory option you must change.
        device = "/dev/sda"; # or "/dev/vda", "/dev/nvme0n1", etc.

        # You can override the defaults if needed.
        # swapSize = "8G";
        # btrfsSubvolumes = {
        #   "/root" = { mountpoint = "/"; };
        #   "/nix" = { mountpoint = "/nix"; };
        #   "/home" = { mountpoint = "/home"; }; # Example: Add a /home subvolume
        # };
      };
    ```
  */

  config = lib.mkIf cfg.enable {
    # Note: This module requires that you have imported the main disko module
    # in your configuration.nix, like so:
    # imports = [inputs.disko.nixosModules.default];

    disko.devices = {
      disk.main = {
        # This will throw an error if cfg.device is not set, as intended.
        inherit (cfg) device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02"; # BIOS boot partition for legacy support
            };
            esp = {
              name = "ESP";
              size = cfg.espSize;
              type = "EF00"; # EFI System Partition
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = cfg.swapSize;
              content = {
                type = "swap";
                resumeDevice = true; # Allows hibernation
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "root_vg";
              };
            };
          };
        };
      };
      lvm_vg = {
        root_vg = {
          type = "lvm_vg";
          lvs = {
            root = {
              size = "100%FREE";
              content = {
                type = "btrfs";
                extraArgs = ["-f"]; # Force creation, useful for re-running disko

                # Dynamically generate the subvolumes config from the module options
                subvolumes =
                  lib.mapAttrs'
                  (name: subvol: lib.nameValuePair name subvol)
                  cfg.btrfsSubvolumes;
              };
            };
          };
        };
      };
    };
  };
}
