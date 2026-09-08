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
  wsl = {
    enable = true;
    usbip.enable = true; # Automatically provisions required binaries for usbipd-win
    defaultUser = user; # Uses "akib" from your flake.nix

    usbip.autoAttach = [
      "1-15"
    ];

    wslConf = {
      boot = {
        systemd = true;
      };

      automount = {
        enabled = true;
        root = "/mnt";
        options = "metadata,uid=1003,gid=1003,umask=077,fmask=11,case=off";
        mountFsTab = true;
      };

      interop = {
        enabled = true;
        appendWindowsPath = true;
      };

      network = {
        hostname = system.name;
        generateHosts = true;
        generateResolvConf = true;
      };
    };
  };

  # Optional but recommended for WSL:
  wsl.startMenuLaunchers = true;
}
