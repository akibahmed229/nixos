{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "akibOS";
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    # ---- helpers ------------------------------------------------------------
    info() { printf "\n----- %s\n" "$1"; }
    die()  { echo "ERROR: $1" >&2; exit 1; }

    # prompt helper (not used interactively here, kept for reuse)
    prompt() { read -r -p "$1: " REPLY; echo "$REPLY"; }

    # check network (simple)
    network_ok() {
      command -v ping >/dev/null 2>&1 && ping -c1 -W3 1.1.1.1 >/dev/null 2>&1
    }

    # safe mount/unmount wrapper for LUKS pendrive copy
    mount_luks() {
      local dev="$1" name="myusb" mnt="/mnt/usb"
      sudo cryptsetup luksOpen "$dev" "$name"
      sudo mkdir -p "$mnt"
      sudo mount "/dev/mapper/$name" "$mnt"
      echo "$mnt"
    }
    unmount_luks() {
      local name="$1" mnt="/mnt/usb}"
      sudo umount "$mnt" || true
      sudo cryptsetup luksClose "$name" || true
    }

    # ---- gather runtime info -----------------------------------------------
    USERNAME="$(id -un)"
    HOSTNAME="$(hostname -s)"
    # try to detect block device backing /boot (fallback to /dev/nvme0n1)
    BOOT_PART="$(lsblk -ln -o NAME,MOUNTPOINT | awk '$2=="/boot" {print $1; exit}')"
    DEVICE="$(if [ -n "$BOOT_PART" ]; then lsblk -no PKNAME "/dev/$BOOT_PART" || true; fi)"
    DEVICE="$DEVICE"

    # flake dir may be provided by env; default to ~/flake
    FLAKE_DIR="$FLAKE_DIR"

    # usb device to use for secrets (env override allowed)
    USB_DEV="/dev/sdb"
    LUKS_NAME="myusb"
    MOUNT_POINT="/mnt/usb"

    info "postInstall started: user=$USERNAME host=$HOSTNAME device=/dev/$DEVICE"

    # ensure network present
    if ! network_ok; then
      die "No network connectivity; aborting."
    fi

    # ---- update flake metadata ---------------------------------------------
    update_flake_data() {
      local repo="$1"
      [ -d "$repo" ] || die "flake dir '$repo' not found"
      # Only replace defaults when user is not original author ("akib")
      if [ "$USERNAME" != "akib" ]; then
        info "Updating flake with local values"
        sed -i "s/akib/$USERNAME/g" "$repo/flake.nix" || true
        sed -i "s/desktop/$HOSTNAME/g" "$repo/flake.nix" || true
        sed -i "s,/dev/nvme0n1,/dev/$DEVICE,g" "$repo/flake.nix" || true
      else
        info "Default author 'akib' detected — skipping flake edits"
      fi
    }

    # ---- copy secrets from encrypted USB (if present) ----------------------
    copy_secrets_from_usb() {
      # skip for author to avoid accidental copy
      if [ "$USERNAME" != "akib" ]; then
        info "skipping secret import"
        return 0
      fi

      # check device exists
      if [ ! -b "$USB_DEV" ]; then
        die "USB device $USB_DEV not found"
      fi

      info "Mounting LUKS USB ($USB_DEV) to copy secrets"
      mount_luks "$USB_DEV" "$LUKS_NAME" "$MOUNT_POINT"

      # guarded copy operations (use -a to preserve attributes where needed)
      sudo mkdir -p "$HOME/.ssh"
      sudo cp -a "$MOUNT_POINT/Backup/gitlab/"* "$HOME/.ssh/" || true
      sudo chmod 700 "$HOME/.ssh"
      sudo chmod 600 "$HOME/.ssh/id_ed25519_gitlab" || true
      sudo chmod 644 "$HOME/.ssh/id_ed25519_gitlab.pub" || true

      sudo mkdir -p /var/lib/sops-nix
      sudo cp -a "$MOUNT_POINT/Backup/AGE/system-keys.txt" /var/lib/sops-nix/keys.txt || true
      mkdir -p "$HOME/.config/sops/age"
      cp -a "$MOUNT_POINT/Backup/AGE/home-key.txt" "$HOME/.config/sops/age/keys.txt" || true

      info "Secrets copied; unmounting USB"
      unmount_luks "$LUKS_NAME" "$MOUNT_POINT"
    }

    # ---- clone flake & run rebuild -----------------------------------------
    install_flake() {
      local repo="$1"
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
    install_flake "$FLAKE_DIR"

    info "Post-install finished"
  '';
}
