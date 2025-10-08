# modules/impermanence.nix
# Configures system persistence using the impermanence module, designed for
# systems with ephemeral root storage (like NixOS on Btrfs subvolumes).
{
  config,
  lib,
  inputs, # Required to import the external impermanence module
  ...
}:
with lib; let
  cfg = config.nm.impermanence;

  # --- Default Directory Definitions ---
  # Define the default system directories to persist
  defaultSystemDirs = [
    # system
    "/root/.local/share"
    "/var/lib/bluetooth"
    "/etc/NetworkManager/system-connections"
    "/var/log"
    "/var/lib/systemd"
    "/var/lib/nixos"
    "/var/lib/systemd/coredump"

    # state for containers and orchestrators
    "/var/lib/docker"
    "/var/lib/kubernetes"
    "/var/lib/cfssl"
    "/var/lib/kubelet"
    "/var/lib/containerd"
    "/var/lib/etcd"
    "/var/lib/flatpak"
    # portainer docker & kubernetes management
    "/var/lib/portainer"
    # pihole
    "/var/lib/pihole/"
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
    "/var/tmp" # special case cleaned by tmpfiles below
    # other
    "/var/lib/microvms"
    "/var/lib/samba/private"
    "/var/lib/waydroid"
    "/var/lib/libvirt"
    "/var/lib/mysql"
    "/var/lib/postgresql"
    "/var/lib/sops-nix/"
    "/run/secrets.d/"
    "/var/lib/jenkins/"
  ];

  # Define the default directories/files for the primary user's home
  defaultUserDirs = [
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
    "pt"
    ".vscode"
    ".docker"
    ".kube"
    ".minikube"
    ".mysql"
    ".rustup"
    ".steam"
    ".elfeed"
    ".cloudflared"
    ".cache" # Persisted, but cleaned by tmpfiles
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
  defaultUserFiles = [".screenrc" ".mysql_history"];
in {
  # --- 0. Conditional Imports ---
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  # --- 1. Define Options ---
  options.nm.impermanence = {
    enable = mkEnableOption "Enable and configure system persistence using the Impermanence module.";

    # MANDATORY: The primary user for whom home directory persistence is configured
    user = mkOption {
      type = types.str;
      description = "The primary user whose home directory will be configured for persistence.";
    };

    mountPoint = mkOption {
      type = types.str;
      default = "/persist";
      description = "The mount point where the persistent data is stored (e.g., /persist).";
    };

    rootDevice = mkOption {
      type = types.str;
      default = "/dev/root_vg/root";
      description = "The device path containing the root filesystem for Btrfs snapshot management during boot.";
    };

    # System Directories (Allows appending via ++)
    systemDirs = mkOption {
      type = types.listOf (types.oneOf [types.str types.attrs]);
      default = [];
      description = "List of system directories/paths to persist under the mount point.";
    };

    # Users Configuration (Allows adding users or merging/overriding primary user's config)
    usersConfig = mkOption {
      type = types.attrsOf (types.submodule ({...}: {
        options = {
          directories = mkOption {
            type = types.listOf (types.oneOf [types.str types.attrs]);
            default = [];
            description = "List of directories to persist in the user's home.";
          };
          files = mkOption {
            type = types.listOf (types.oneOf [types.str types.attrs]);
            default = [];
            description = "List of files to persist in the user's home.";
          };
        };
      }));
      default = {};
      description = "Configuration for additional users or to override the primary user's default persistence list.";
    };
  };

  /*
  # Example of usage
  nm.impermanence = {
    enable = true;
    user = "alice"; # REQUIRED: Set your primary username

    # Optional: Override the Btrfs device path if needed
    # rootDevice = "/dev/disk/by-label/NIXOS_ROOT";

    # --- Appending System Directories ---
    # Append a new system directory to the default list (using ++)
    systemDirs = config.nm.impermanence.systemDirs ++ [
      "/var/lib/my-new-service-state"
    ];

    # --- Configuring Users ---
    usersConfig = {
      # Override: Use mkMerge to customize the primary user's config
      # This removes the default .cache persistence and adds a new folder
      alice = lib.mkMerge [
        {
          directories = [ "MyCodeProjects" ];
        }
        # Keep the rest of the defaults for Alice
        (lib.attrByPath [ "nm" "impermanence" "usersConfig" "alice" ] {} config)
      ];

      # Add: Configure persistence for a secondary user "afif"
      afif = {
        directories = [
          "Downloads"
          {
            directory = ".mozilla";
            mode = "0700";
          }
        ];
      };
    };
  };
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2a. Btrfs Snapshot Logic (Cleaning up old roots)
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      mkdir /btrfs_tmp
      mount ${cfg.rootDevice} /btrfs_tmp
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

    # 2b. File Systems
    fileSystems."${cfg.mountPoint}".neededForBoot = true;
    fileSystems."/var/lib/sops-nix".neededForBoot = true;

    # 2c. Impermanence persistence setup
    environment.persistence."${cfg.mountPoint}" = {
      hideMounts = true;

      # Use the combined list of default + user-added system directories
      directories = defaultSystemDirs ++ cfg.systemDirs;

      files = [
        "/etc/machine-id"
      ];

      # 3. Configure persistence for all users
      users = mkMerge [
        # 1. Start with the default configuration for the single primary user
        {
          ${cfg.user} = {
            directories = defaultUserDirs;
            files = defaultUserFiles;
          };
        }
        # 2. Merge user-provided configurations (allowing overrides/additions)
        cfg.usersConfig
      ];
    };

    # 2d. systemd-tmpfiles Rules
    systemd.tmpfiles.rules = [
      # FIX: mkdir: cannot create directory "/persist/home": Permission denied
      # "d /persist/home/ 0777 root root -" # create /persist/home owned by root
      # ''d /persist/home/${user} 0700 "${user}" users -'' # /persist/home/<user> owned by that user

      "e /var/tmp 1777 root root 30d"
      # Clean old contents in user home cache dir
      "e /home/${cfg.user}/.cache 755 ${cfg.user} users 7d"
      "r /home/${cfg.user}/.cache/tmp*" # remove temporary files in cache on every boot

      # exceptions
      "x /home/${cfg.user}/.cache/rbw"
      "x %h/.cache/borg" # caches checksums of file chunks for deduplication
    ];

    # 2e. Programs
    programs.fuse.userAllowOther = true;
  };
}
