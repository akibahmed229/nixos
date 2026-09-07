{
  inputs,
  user,
  system,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Import the wsl module directly from your flake inputs
    inputs.nixos-wsl.nixosModules.default
  ];

  # Basic WSL Configuration
  wsl.enable = true;
  wsl.defaultUser = user; # Uses "akib" from your flake.nix

  # Optional but recommended for WSL:
  wsl.startMenuLaunchers = true;

  # Enable Nix Flakes in the WSL instance
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # System state version (you can also map this to your global state-version if preferred)
  system.stateVersion = "24.05";
}
