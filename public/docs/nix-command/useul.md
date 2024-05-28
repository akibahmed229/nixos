1. `sudo nix-store --repair --verify --check-contents` - Check the integrity of the Nix store and repair any inconsistencies. This command is useful if you suspect that the Nix store has been corrupted or if you are experiencing issues with your Nix installation

2. `sudo nix-env --list-generations --profile /nix/var/nix/profiles/system` - List all the generations of the system profile.

3. `sudo nix-collect-garbage -d` - Remove all the unused packages from the Nix store.

4. `nix-prefetch-url "https://discord.com/api/download?platform=linux&format=tar.gz"` - Fetch the hash of a remote file. This is useful when you want to add a new package to your Nix configuration.
