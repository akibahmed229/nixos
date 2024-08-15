1. `sudo nix-store --repair --verify --check-contents` - Check the integrity of the Nix store and repair any inconsistencies. This command is useful if you suspect that the Nix store has been corrupted or if you are experiencing issues with your Nix installation
2. `sudo nix-env --list-generations --profile /nix/var/nix/profiles/system` - List all the generations of the system profile.

3. `sudo nix-collect-garbage -d` - Remove all the unused packages from the Nix store.

4. `nix-prefetch-url "https://discord.com/api/download?platform=linux&format=tar.gz"` - Fetch the hash of a remote file. This is useful when you want to add a new package to your Nix configuration.

5. `nix flake update --commit-lock-file --accept-flake-config` - Update the flake.lock file and accept the changes in the flake configuration. This command is useful when you want to update the dependencies of a flake project.

6. `nix-eval --file default.nix` - Evaluate a Nix expression in a file. This command is useful when you want to test a Nix expression before using it in your configuration.

7. `nix flake metadata --json | nix run nixpkgs\#jq` - Get the metadata of a flake and use jq to parse the JSON output. This command is useful when you want to inspect the metadata of a flake.

8. `sudo nixos-rebuild switch --flake .#host --option tarball-ttl 0` Will not use cache to rebuild

9. `nixos-rebuild --use-remote-sudo switch --flake .#host` will append for sudo while system activation script

10. Switching Generations without reboot

```bash
nix-env --list-generations -p /nix/var/nix/profiles/system
nix-env --switch-generation <number> -p /nix/var/nix/profiles/system
# sets selected generation to be activated
/nix/var/nix/profiles/system/bin/switch-to-configuration { switch or boot }
```

Set current config to default boot

use this when you boot a previous generation via the boot manager menu and want it to be set to default on next boot

`/run/current-system/bin/switch-to-configuration { switch or boot }`
