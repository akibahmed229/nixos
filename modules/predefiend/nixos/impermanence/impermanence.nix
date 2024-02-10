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
      "/etc/NetworkManager/system-connections"
      "/var/log" # system logs
      "/var/lib/systemd" # various state for systemd such as persistent timers
      "/var/lib/nixos"
      "/var/lib/docker" # TODO: remove once I got rid of Docker on sapphire
      /*
        /var/tmp is expected to be on disk and have enough free space
        e.g. by podman when copying images, which will easily fill up the tmpfs

        so we persist this and add a systemd-tmpfiles rule below to clean it up
        on a schedule
        */
      "/var/tmp"
      "/root/.local/share" # various application state
      "/etc/mullvad-vpn"
      "/var/cache/mullvad-vpn" # mullvad vpn cli client settings and relay list cache
      "/var/lib/bluetooth" # bluetooth connection state stuff
      "/var/lib/microvms" # MicroVMs
      "/var/lib/flatpak" # flatpak user data
    ];
    files = [
      "/etc/machine-id"
      { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
    users.${user} = {
      directories = [
        "Desktop"
        "Downloads"
        "Music"
        "Pictures"
        "Public"
        "Documents"
        "Videos"
        "VirtualBox VMs"
        "flake"
        "Android"
        ".vscode"
        ".docker"
        ".cache" # is persisted, but kept clean with systemd-tmpfiles, see below
        { directory = ".gnupg"; mode = "0700"; }
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".config"; mode = "0700"; }
        { directory = ".mozilla"; mode = "0700"; }
        { directory = ".nixops"; mode = "0700"; }
        { directory = ".tmux"; mode = "0700"; }
        { directory = ".local/share/keyrings"; mode = "0700"; }
        ".local/share/direnv"
        ".local/share/nvim"
        ".local/share/TelegramDesktop"
        ".local/share/whatsapp-for-linux"
        ".local/share/Notepadqq"
        ".local/share/qBittorrent"
        ".local/share/flatpak"
        ".local/state/nvim"
        ".local/state/wireplumber"
      ];
      files = [
        ".screenrc"
        #".zshrc"
        ".zsh_history"
        ".gitconfig"
      ];
    };
  };

  # /var/tmp is persisted for reasons explained above, clean it with systemd-tmpfiles
  systemd.tmpfiles.rules = [ "e /var/tmp 1777 root root 30d" ];
  # allows other users to access FUSE mounts
  programs.fuse.userAllowOther = true;
  #  home-manager = {
  #   extraSpecialArgs = {inherit inputs;};
  #   users.${user} = import ./../../home-manager/impermanence/impermanence.nix;
  # }; 
}
