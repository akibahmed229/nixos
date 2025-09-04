{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "akibOS";
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    # ---- helpers ------------------------------------------------------------
    info() { printf "\n----- %s\n" "$1"; }
    die()  { echo "ERROR: $1" >&2; exit 1; }

    prompt() { read -r -p "$1: " REPLY; echo "$REPLY"; }

    network_ok() {
      command -v ping >/dev/null 2>&1 && ping -c1 -W3 1.1.1.1 >/dev/null 2>&1
    }

    mount_luks() {
      local dev="$1" name="myusb" mnt="/mnt/usb"
      sudo cryptsetup luksOpen "$dev" "$name"
      sudo mkdir -p "$mnt"
      sudo mount "/dev/mapper/$name" "$mnt"
      echo "$mnt"
    }
    unmount_luks() {
      local name="$1" mnt="/mnt/usb"
      sudo umount "$mnt" || true
      sudo cryptsetup luksClose "$name" || true
    }

    # ---- runtime info -------------------------------------------------------
    USERNAME="$(id -un)"
    HOSTNAME="$(hostname -s)"
    BOOT_PART="$(lsblk -ln -o NAME,MOUNTPOINT | awk '$2=="/boot" {print $1; exit}')"
    DEVICE="$(if [ -n "$BOOT_PART" ]; then lsblk -no PKNAME "/dev/$BOOT_PART" || true; fi)"

    # ask user for USB device (instead of hardcoding)
    info "Available block devices:"
    lsblk -dpno NAME,SIZE,MODEL | grep -E "/dev/"
    USB_DEV="$(prompt "Enter USB device path (e.g., /dev/sdb)")"
    [ -b "$USB_DEV" ] || die "Invalid block device: $USB_DEV"

    LUKS_NAME="myusb"
    MOUNT_POINT="/mnt/usb"

    info "postInstall started: user=$USERNAME host=$HOSTNAME device=/dev/$DEVICE usb=$USB_DEV"

    if ! network_ok; then
      die "No network connectivity; aborting."
    fi

    # ---- update flake metadata ---------------------------------------------
    update_flake_data() {
      local repo="$1"
      [ -d "$repo" ] || die "flake dir '$repo' not found"
      if [ "$USERNAME" != "akib" ]; then
        info "Updating flake with local values"
        sed -i "s/akib/$USERNAME/g" "$repo/flake.nix" || true
        sed -i "s/desktop/$HOSTNAME/g" "$repo/flake.nix" || true
        sed -i "s/\?ref=main&shallow=1//g" "$repo/flake.nix" || true
        sed -i "s,/dev/nvme0n1,/dev/$DEVICE,g" "$repo/flake.nix" || true
      else
        info "Default author 'akib' detected — skipping flake edits"
      fi
    }

    # ---- copy secrets from encrypted USB -----------------------------------
    copy_secrets_from_usb() {
      if [ "$USERNAME" != "akib" ]; then
        info "Running as $USERNAME — skipping secret import"
        return 0
      fi

      info "Mounting LUKS USB ($USB_DEV) to copy secrets"
      mount_luks "$USB_DEV" "$LUKS_NAME" "$MOUNT_POINT"

      sudo mkdir -p "/home/$USERNAME/.ssh"
      sudo cp -a "$MOUNT_POINT/Backup/gitlab/id_ed25519_gitlab" "/home/$USERNAME/.ssh/" || true
      sudo cp -a "$MOUNT_POINT/Backup/gitlab/id_ed25519_gitlab.pub" "/home/$USERNAME/.ssh/" || true
      sudo chmod 700 "/home/$USERNAME/.ssh"
      sudo chown "$USERNAME":users "/home/$USERNAME/.ssh/id_ed25519_gitlab" || true
      sudo chown "$USERNAME":users "/home/$USERNAME/.ssh/id_ed25519_gitlab.pub" || true
      sudo chmod 600 "/home/$USERNAME/.ssh/id_ed25519_gitlab" || true
      sudo chmod 644 "/home/$USERNAME/.ssh/id_ed25519_gitlab.pub" || true

      sudo mkdir -p /var/lib/sops-nix
      sudo cp -a "$MOUNT_POINT/Backup/AGE/system-keys.txt" /var/lib/sops-nix/keys.txt || true
      mkdir -p "/home/$USERNAME/.config/sops/age"
      cp -a "$MOUNT_POINT/Backup/AGE/home-key.txt" "/home/$USERNAME/.config/sops/age/keys.txt" || true

      # Configure SSH to use the GitLab key
      echo -e "Host gitlab.com\n  User git\n  IdentityFile /home/$USERNAME/.ssh/id_ed25519_gitlab\n  IdentitiesOnly yes" >> "/home/$USERNAME/.ssh/config"
      sudo chown "$USERNAME":users "/home/$USERNAME/.ssh/config"
      chmod 600 "/home/$USERNAME/.ssh/config"


      info "Secrets copied; unmounting USB"
      unmount_luks "$LUKS_NAME" "$MOUNT_POINT"
    }

    # ---- clone flake & run rebuild -----------------------------------------
    install_flake() {
      local repo="$FLAKE_DIR"
      mkdir -p "$repo"
      cd "$repo"

      info "Cloning flake repository (shallow)"
      git clone https://www.github.com/akibahmed229/nixos . --depth 1 || die "git clone failed"

      update_flake_data "$repo"
      info "Running nixos-rebuild switch for $HOSTNAME"
      sudo nixos-rebuild switch --flake ".#$HOSTNAME" --show-trace
    }

    # ---- main ---------------------------------------------------------------
    copy_secrets_from_usb
    ssh git@gitlab.com
    install_flake

    info "Post-install finished"
  '';
}
