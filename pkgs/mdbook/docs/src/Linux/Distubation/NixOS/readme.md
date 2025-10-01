# NixOS Command Cheatsheet

## A collection of useful Nix and NixOS commands for system management.

---

### System & Store Maintenance

- **Verify & Repair Store**: Checks the integrity of the Nix store and repairs any issues. Use this if you suspect corruption.

  ```bash
  sudo nix-store --repair --verify --check-contents
  ```

- **Garbage Collection**: Removes all unused packages from the Nix store to free up space.

  ```bash
  sudo nix-collect-garbage -d
  sudo nix-collect-garbage --delete-older-than 7d
  sudo nix store gc
  ```

---

### Generation Management

- **List System Generations**: Shows all past system configurations (generations).

  ```bash
  sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
  ```

- **Switch Generation (No Reboot)**: Allows you to roll back to a previous system configuration without restarting.
  1.  List generations:

      ```bash
      nix-env --list-generations -p /nix/var/nix/profiles/system
      ```

  2.  Switch to generation:

      ```bash
      sudo nix-env --switch-generation <number> -p /nix/var/nix/profiles/system
      ```

  3.  Activate configuration:

      ```bash
      sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
      ```

  4.  Set Booted Generation as Default: If you boot into an older generation, run this to make it the default.

      ```bash
      /run/current-system/bin/switch-to-configuration boot
      ```

---

### System Rebuilding

- **Rebuild without Cache**: Forces a rebuild without using cached tarballs.
  ```bash
  sudo nixos-rebuild switch --flake .#host --option tarball-ttl 0
  ```
- **Rebuild on a Remote Machine**: Uses `sudo` on a remote machine during activation.
  ```bash
  nixos-rebuild --use-remote-sudo switch --flake .#host
  ```

---

### Flake Management

- **Update Flake Inputs**: Updates flake dependencies and commits to `flake.lock`.

  ```bash
  nix flake update --commit-lock-file --accept-flake-config
  ```

- **Inspect Flake Metadata**: Shows flake metadata in JSON format.

  ```bash
  nix flake metadata --json | nix run nixpkgs#jq
  ```

---

### Development & Packaging

- **Prefetch URL**: Downloads a file and prints its hash. Essential for packaging.

  ```bash
  nix-prefetch-url "https://discord.com/api/download?platform=linux&format=tar.gz"
  ```

- **Evaluate a Nix File**: Tests a Nix expression from a file.

  ```bash
  nix-eval --file default.nix
  ```

---

### Nixpkgs Legacy: Using Old OpenSSH with DSS

Sometimes you need to connect to legacy SSH servers that only support **ssh-dss** (DSA) keys. Modern Nixpkgs disables DSS by default, but you can pin an older package.

#### 1. Create a Nix file for legacy OpenSSH

**`legacy-ssh.nix`**:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  # Pin an older nixpkgs commit with DSS support
  legacyPkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/2f6ef9aa6a7eecea9ff7e185ca40855f36597327.tar.gz";
    sha256 = "0jcs9r4q57xgnbrc76davqy10b1xph15qlkvyw1y0vk5xw5vmxfz";
  }) {};
in
  legacyPkgs.openssh
```

> Browse older package versions: [Nix Versions](https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=openssh)

#### 2. Build the package

```bash
nix build -f legacy-ssh.nix
```

#### 3. Use the legacy `ssh` binary

```bash
./result/bin/ssh -F /dev/null \
  -o HostKeyAlgorithms=ssh-dss \
  -o KexAlgorithms=diffie-hellman-group1-sha1 \
  -o PreferredAuthentications=password,keyboard-interactive \
  admin@192.168.0.1 -vvv
```

**Explanation of key options:**

- `-F /dev/null` → Ignore default SSH config.
- `HostKeyAlgorithms=ssh-dss` → Allow DSS host keys.
- `KexAlgorithms=diffie-hellman-group1-sha1` → Use legacy key exchange.
- `PreferredAuthentications=password,keyboard-interactive` → Only use password or interactive login.
