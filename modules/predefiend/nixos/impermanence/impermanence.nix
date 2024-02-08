{ pkgs, lib, user, inputs, ... }:

{
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
    ];
    files = [
      "/etc/machine-id"
      { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
    #users.${user} = {
    #  directories = [
    #    "Desktop"
    #    "Downloads"
    #    "Music"
    #    "Pictures"
    #    "Public"
    #    "Documents"
    #    "Videos"
    #    "VirtualBox VMs"
    #    "flake"
    #    "Android"
    #    ".docker"
    #    ".cache" # is persisted, but kept clean with systemd-tmpfiles, see below
    #    { directory = ".gnupg"; mode = "0700"; }
    #    { directory = ".ssh"; mode = "0700"; }
    #    { directory = ".config"; mode = "0700"; }
    #    { directory = ".mozilla"; mode = "0700"; }
    #    { directory = ".nixops"; mode = "0700"; }
    #    { directory = ".tmux"; mode = "0700"; }
    #    { directory = ".local/share/keyrings"; mode = "0700"; }
    #    ".local/share/direnv"
    #  ];
    #  files = [
    #    ".screenrc"
    #    ".zshrc"
    #    ".zsh_history"
    #    ".gitconfig"
    #  ];
    #};
  };

  programs.fuse.userAllowOther = true;
  #  home-manager = {
  #   extraSpecialArgs = {inherit inputs;};
  #   users.${user} = import ./../../home-manager/impermanence/impermanence.nix;
  # }; 
}
