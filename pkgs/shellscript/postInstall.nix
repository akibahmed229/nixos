{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "akibOS";
  runtimeInputs = with pkgs; [
    git
    coreutils
    gnugrep
    gnused
  ];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    # ---- helpers ------------------------------------------------------------
    function info() { printf "\n----- %s\n" "$1"; }
    function die()  { echo "ERROR: $1" >&2; exit 1; }

    function prompt() { read -r -p "$1: " REPLY; echo "$REPLY"; }

    function network_ok() {
      command -v ping >/dev/null 2>&1 && ping -c1 -W3 1.1.1.1 >/dev/null 2>&1
    }

    # ---- runtime info -------------------------------------------------------
    USERNAME="$(id -un)"
    HOSTNAME="$(hostname -s)"
    BOOT_PATH="$(lsblk -l | grep -i "boot" | awk '{print $1}')"
    DEVICE="$(lsblk -no pkname /dev/"$BOOT_PATH")"

    # ask user for USB device (instead of hardcoding)
    if [[ "$USERNAME" == "akib" ]]; then
      info "Available block devices:"
      lsblk -dpno NAME,SIZE,MODEL | grep -E "/dev/"
      USB_DEV="$(prompt "Enter USB device path (e.g., /dev/sdb)")"
      [ -b "$USB_DEV" ] || die "Invalid block device: $USB_DEV"
    else
      USB_DEV="/dev/$DEVICE"
    fi

    LUKS_NAME="myusb"
    MOUNT_POINT="/mnt/usb"

    info "postInstall started: user=$USERNAME host=$HOSTNAME device=/dev/$DEVICE usb=$USB_DEV"

    if ! network_ok; then
      die "No network connectivity; aborting."
    fi

    function mount_luks() {
      local dev="$1" name="$2" mnt="$3"
      sudo cryptsetup luksOpen "$dev" "$name"
      sudo mkdir -p "$mnt"
      sudo mount "/dev/mapper/$name" "$mnt"
      echo "$mnt"
    }
    function unmount_luks() {
      local name="$1" mnt="$2"
      sudo umount "$mnt" || true
      sudo cryptsetup luksClose "$name" || true
    }

    # ---- update flake metadata ---------------------------------------------
    function update_flake_data() {
      local repo="$1"
      cd "$repo"

     [ -d "$repo" ] || die "flake dir '$repo' not found"
        info "Updating flake with local values"
        sed -i "s/akib/$USERNAME/g" "$repo/flake.nix" || true
        sed -i "s,/dev/nvme1n1,/dev/$DEVICE,g" "$repo/flake.nix" || true

     if [[ "$USERNAME" != "akib" ]]; then
        sed -i '/secrets = {/,/};/d' "$repo/flake.nix"
     fi

      nix flake update
    }

    # ---- copy secrets from encrypted USB -----------------------------------
    function copy_secrets_from_usb() {
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
    function install_flake() {
      local repo="$FLAKE_DIR"
      mkdir -p "$repo"
      cd "$repo"

      info "Cloning flake repository (shallow)"

      git clone https://www.github.com/akibahmed229/nixos . --depth 1 || die "git clone failed"

      update_flake_data "$repo"
      info "Running nixos-rebuild switch for $HOSTNAME"
      sudo nixos-rebuild switch --flake ".#$HOSTNAME" --show-trace
    }

    # ---- Maintainer Related ---------------------------------------------------------------
    function maintenance() {
      if [[ "$USERNAME" == "akib" ]]; then
        cd "$FLAKE_DIR"
        git remote remove origin || true
        git remote add github gh:akibahmed229/nixos.git
        git remote add gitlab gl:akibahmed/nixos.git

        git submodule init
        git submodule update

        mkdir -p modules/predefiend/nixos/sops/config
        cd modules/predefiend/nixos/sops/config
        git clone gl:akibahmed/sops-secrects.git || true
      fi
    }

    # ---- main ---------------------------------------------------------------
    copy_secrets_from_usb
    sleep 1
    install_flake
    sleep 1
    maintenance

    info "Post-install finished"
  '';
}
