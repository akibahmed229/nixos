/*
# /etc/nixos/modules/sftp.nix
#
# This module configures an rclone SFTP mount, allowing you to mount
# a remote directory into the local filesystem declaratively.
*/
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Short-hand for the configuration options of this module.
  cfg = config.nm.sftp;
in {
  # Define the options that users of this module can set.
  options.nm.sftp = with lib; {
    enable = mkEnableOption "rclone SFTP mount";

    remoteName = mkOption {
      type = types.str;
      default = "myremote";
      description = "A unique name for this rclone remote configuration.";
    };

    remoteHost = mkOption {
      type = types.str;
      example = "192.168.0.103";
      description = "The hostname or IP address of the remote SFTP server.";
    };

    remotePort = mkOption {
      type = types.port;
      default = 22;
      description = "The port number of the remote SFTP server.";
    };

    remoteUser = mkOption {
      type = types.str;
      example = "user";
      description = "The username to connect to the remote SFTP server.";
    };

    remotePath = mkOption {
      type = types.path;
      example = "/sdcard";
      description = "The absolute path on the remote server to be mounted.";
    };

    localMountPoint = mkOption {
      type = types.path;
      example = "/mnt/sdcard";
      description = "The local directory where the remote path will be mounted.";
    };

    sshKeyPath = mkOption {
      type = types.path;
      example = "/home/user/.ssh/id_ed25519";
      description = "The absolute path to the SSH private key for authentication.";
    };
  };
  /*

  * SFTP Mount
  * ssh-copy-id -f -p 90 user@host # Copy the public key to the remote host
  * ssh -p 90 user@host # Test the connection to the remote host
  * rclone config # Configure the remote SFTP connection
  * rclone mount myremote:/sdcard /mnt/sdcard --config /etc/rclone-mnt.conf --allow-other --daemon # Mount the remote SFTP path
  * fusermount -u /mnt/sdcard # Unmount the remote SFTP path
  * systemctl --user start rclone-mnt # Start the rclone mount service


  # Example Usage
  ```nix
    # Configure the SFTP mount using the new module
    nm.sftp = {
        enable = true;
        remoteHost = "192.168.0.103";
        remotePort = 8022;
        remoteUser = "your_user_name"; # Make sure this user exists
        remotePath = "/sdcard";
        localMountPoint = "/mnt/sdcard";
        sshKeyPath = "/home/your_user_name/.ssh/id_ed25519";
      };
    }
  ```
  */

  # Configure the system based on the options defined above.
  config = lib.mkIf cfg.enable {
    # 1. Add rclone to the system packages.
    environment.systemPackages = [pkgs.rclone];

    # 2. Create the rclone configuration file in /etc.
    #    The filename is based on the remoteName to avoid conflicts.
    environment.etc."rclone-${cfg.remoteName}.conf".text = ''
      [${cfg.remoteName}]
      type = sftp
      host = ${cfg.remoteHost}
      user = ${cfg.remoteUser}
      key_file = ${cfg.sshKeyPath}
      port = ${toString cfg.remotePort}
    '';

    # 3. Define the filesystem mount.
    #    This uses systemd's mount capabilities for robustness.
    fileSystems."${cfg.localMountPoint}" = {
      device = "${cfg.remoteName}:${cfg.remotePath}";
      fsType = "rclone";
      options = [
        "nodev" # Do not interpret block special devices on the filesystem.
        "nofail" # Do not report errors for this device if it does not exist.
        "allow_other" # Allow other users to access the mount point.
        "args2env"
        "config=/etc/rclone-${cfg.remoteName}.conf"
        "_netdev" # Ensures the network is available before attempting to mount.
      ];
    };
  };
}
