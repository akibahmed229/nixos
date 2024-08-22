/*
* SFTP Mount
* ssh-copy-id -f -p 90 user@host # Copy the public key to the remote host
* ssh -p 90 user@host # Test the connection to the remote host
* rclone config # Configure the remote SFTP connection
* rclone mount myremote:/sdcard /mnt/sdcard --config /etc/rclone-mnt.conf --allow-other --daemon # Mount the remote SFTP path
* fusermount -u /mnt/sdcard # Unmount the remote SFTP path
* systemctl --user start rclone-mnt # Start the rclone mount service
*/
{
  pkgs,
  user,
  ...
}: let
  # Define the remote SFTP path and the local mount point
  remoteHost = "192.168.0.103";
  remotePort = "8022";
  remotePath = "/sdcard";
  localMountPoint = "/mnt/sdcard";
  sshKey = "/home/${user}/.ssh/id_ed25519";
in {
  environment.systemPackages = [pkgs.rclone];
  environment.etc."rclone-mnt.conf".text = ''
    [myremote]
    type = sftp
    host = ${remoteHost}
    user = ${user}
    key_file = ${sshKey}
    port = ${remotePort}
  '';

  # Ensure the directory for the mount point exists
  fileSystems."${localMountPoint}" = {
    device = "myremote:${remotePath}";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=/etc/rclone-mnt.conf"
    ];
  };
}
