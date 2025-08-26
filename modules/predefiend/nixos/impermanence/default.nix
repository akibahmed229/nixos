/*
Modules to help you handle persistent state on systems with ephemeral root storage
*/
{
  lib,
  user,
  inputs,
  ...
}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

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
  fileSystems."/var/lib/sops-nix".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      # system
      "/root/.local/share" # various application state
      "/var/lib/bluetooth" # bluetooth connection state stuff
      "/etc/NetworkManager/system-connections"
      "/var/log" # system logs
      "/var/lib/systemd" # various state for systemd such as persistent timers
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"

      # state for containers and orchestrators
      "/var/lib/docker"
      "/var/lib/kubernetes"
      "/var/lib/kubelet"
      "/var/lib/containerd"
      "/var/lib/etcd"
      "/var/lib/flatpak"
      # portainer docker & kubernetes management
      "/var/lib/portainer"
      #  pihole
      "/var/lib/pihole/"
      "/var/lib/dnsmasq.d" # dnsmasq is free software providing Domain Name System (DNS) caching, a Dynamic Host Configuration Protocol (DHCP) server, router advertisement and network boot features, intended for small computer networks. dnsmasq.
      # Nextcloud
      "/var/lib/mariadb"
      "/var/lib/nextcloud/html"
      "/var/lib/nextcloud/data"
      # ngnix proxy manager
      "/var/lib/ngnixproxymanager"
      "/var/lib/letsencrypt"
      # n8n
      "/var/lib/postgresqln8n"
      "/var/lib/ollama"
      # "/var/lib/ollama-webui"

      /*
      /var/tmp is expected to be on disk and have enough free space
      e.g. by podman when copying images, which will easily fill up the tmpfs

      so we persist this and add a systemd-tmpfiles rule below to clean it up
      on a schedule
      */
      "/var/tmp"

      # other
      "/var/lib/microvms" # MicroVMs
      "/var/lib/samba/private" # storing samba user password
      "/var/lib/waydroid" # waydroid state
      "/var/lib/libvirt" # libvirt state for VMs
      "/var/lib/mysql"
      "/var/lib/postgresql"
      "/var/lib/sops-nix/"
      "/run/secrets.d/"
    ];
    files = [
      "/etc/machine-id" # TODO: investigate if this is needed
      # { file = "/var/lib/sops-nix/secret_file"; parentDirectory = { mode = "u=rwx,g=rwx,o=rwx"; }; }
    ];
    users = {
      ${user} = {
        directories = [
          "Desktop"
          "Downloads"
          "Music"
          "Pictures"
          "Public"
          "Documents"
          "Videos"
          "VirtualBox VMs"
          "Android"
          "Postman"
          "Games"
          "pt" # FIXME: remove this once work networking course is done
          ".vscode"
          ".docker"
          ".kube"
          ".minikube"
          ".mysql"
          ".rustup"
          ".steam"
          ".elfeed"
          ".cloudflared"
          ".cache" # is persisted, but kept clean with systemd-tmpfiles, see below
          {
            directory = ".gnupg";
            mode = "0700";
          }
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".config";
            mode = "0700";
          }
          {
            directory = ".mozilla";
            mode = "0700";
          }
          {
            directory = ".nixops";
            mode = "0700";
          }
          {
            directory = ".tmux";
            mode = "0700";
          }
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }
          ".local/share/direnv"
          ".local/share/nvim"
          ".local/share/TelegramDesktop"
          ".local/share/wasistlos"
          ".local/share/Notepadqq"
          ".local/share/qBittorrent"
          ".local/share/zsh"
          ".local/share/flatpak"
          ".local/state/nvim"
          ".local/state/wireplumber"
          ".local/share/atuin"
          ".local/share/Steam"
          ".local/share/lutris"
          ".local/share/zed"
          ".local/zed.app"
          ".local/share/org.localsend.localsend_app"
          ".var/app/sh.ppy.osu"
        ];
        files = [
          ".screenrc"
          ".mysql_history"
        ];
      };
      # "afif" = {
      #   directories = [
      #     "Downloads"
      #     {
      #       directory = ".mozilla";
      #       mode = "0700";
      #     }
      #   ];
      # };
    };
  };

  # /var/tmp is persisted for reasons explained above, clean it with systemd-tmpfiles
  systemd.tmpfiles.rules = [
    # FIX: mkdir: cannot create directory "/persist/home": Permission denied
    # "d /persist/home/ 0777 root root -" # create /persist/home owned by root
    # ''d /persist/home/${user} 0700 "${user}" users -'' # /persist/home/<user> owned by that user

    "e /var/tmp 1777 root root 30d"
    #  /*
    #    clean old contents in home cache dir
    #    (it's persisted to avoid problems with large files being loaded into the tmpfs)
    #  */
    "e /home/${user}/.cache 755 ${user} users 7d"
    "r /home/${user}/.cache/tmp*" # remove temporary files in cache on every boot

    # exceptions
    "x /home/${user}/.cache/rbw"
    "x %h/.cache/borg" # caches checksums of file chunks for deduplication
  ];

  # allows other users to access FUSE mounts
  programs.fuse.userAllowOther = true;
}
