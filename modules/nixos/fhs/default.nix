# This module configures the system to support non-NixOS binaries by creating
# a custom FHS shell environment ('fhs' command) and enabling the nix-ld dynamic
# linker wrapper for maximum compatibility.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.fhs;

  # Packages manually added to the original FHS environment
  defaultFhsPackages = with pkgs; [
    pkg-config
    ncurses
  ];

  # Libraries required by the original nix-ld configuration (essential for C/C++ binaries)
  defaultNixLdLibraries = [
    pkgs.stdenv.cc.cc
  ];
in {
  # --- 1. Define Options ---
  options.nm.fhs = {
    enable = mkEnableOption "Enable FHS shell environment ('fhs' command) and nix-ld for non-NixOS binaries";

    extraFhsPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of extra packages to include inside the 'fhs' environment (e.g., glibc, X11 libraries) to satisfy dependencies.";
    };

    extraNixLdLibraries = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of extra shared libraries to expose globally via nix-ld (e.g., specific GPU drivers or non-NixOS dependencies).";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 FHS Environment (the 'fhs' command)
    # This creates a dedicated 'fhs' command that drops the user into a bash shell
    # with a conventional FHS structure, allowing most non-NixOS software to run.
    environment.systemPackages = [
      (let
        base = pkgs.appimageTools.defaultFhsEnvArgs;
      in
        pkgs.buildFHSEnv (base
          // {
            name = "fhs";
            targetPkgs = pkgs: (
              # Start with appimageTools' defaults, add base packages, and then user extras.
              (base.targetPkgs pkgs)
              ++ defaultFhsPackages
              ++ cfg.extraFhsPackages
            );
            profile = "export FHS=1"; # Set a helpful environment variable
            runScript = "bash";
            extraOutputsToInstall = ["dev"];
          }))
    ];

    # 2.2 Nix-ld Configuration
    # nix-ld installs a dynamic linker wrapper to run non-NixOS binaries directly
    # without needing the 'fhs' shell.
    programs.nix-ld = {
      enable = true; # Enabled conditionally on nm.fhs.enable
      libraries = defaultNixLdLibraries ++ cfg.extraNixLdLibraries;
    };
  };
}
