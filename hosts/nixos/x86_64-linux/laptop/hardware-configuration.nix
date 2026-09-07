{
  inputs,
  lib,
  pkgs,
  user,
  ...
}: {
  # Basic WSL Configuration
  wsl.enable = true;
  wsl.defaultUser = user; # Uses "akib" from your flake.nix

  # Optional but recommended for WSL:
  wsl.startMenuLaunchers = true;
}
