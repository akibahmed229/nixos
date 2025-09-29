{state-version, ...}: {
  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    accept-flake-config = true # Enable substitution from flake.nix
    warn-dirty = false
  '';

  # Set your time zone
  time.timeZone = "Asia/Dhaka";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";
}
