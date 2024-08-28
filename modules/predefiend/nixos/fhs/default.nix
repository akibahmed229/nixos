/*
# Activating FHS drops me into a shell that resembles a "normal" Linux environment.
fhs
# Check what we have in /usr/bin.
  (fhs) $ ls /usr/bin
# Try running a non-NixOS binary downloaded from the Internet.
  (fhs) $ ./bin/code
*/
{pkgs, ...}: {
  # ......omit many configurations

  environment.systemPackages = with pkgs; [
    # ......omit many packages

    # Create an FHS environment using the command `fhs`, enabling the execution of non-NixOS packages in NixOS!
    (let
      base = pkgs.appimageTools.defaultFhsEnvArgs;
    in
      pkgs.buildFHSUserEnv (base
        // {
          name = "fhs";
          targetPkgs = pkgs: (
            # pkgs.buildFHSUserEnv provides only a minimal FHS environment,
            # lacking many basic packages needed by most software.
            # Therefore, we need to add them manually.
            #
            # pkgs.appimageTools provides basic packages required by most software.
            (base.targetPkgs pkgs)
            ++ (with pkgs; [
              pkg-config
              ncurses
              # Feel free to add more packages here if needed.
            ])
          );
          profile = "export FHS=1";
          runScript = "bash";
          extraOutputsToInstall = ["dev"];
        }))
  ];

  # ......omit many configurations

  # https://github.com/Mic92/nix-ld
  #
  # nix-ld will install itself at `/lib64/ld-linux-x86-64.so.2` so that
  # it can be used as the dynamic linker for non-NixOS binaries.
  #
  # nix-ld works like a middleware between the actual link loader located at `/nix/store/.../ld-linux-x86-64.so.2`
  # and the non-NixOS binaries. It will:
  #
  #   1. read the `NIX_LD` environment variable and use it to find the actual link loader.
  #   2. read the `NIX_LD_LIBRARY_PATH` environment variable and use it to set the `LD_LIBRARY_PATH` environment variable
  #      for the actual link loader.
  #
  # nix-ld's nixos module will set default values for `NIX_LD` and `NIX_LD_LIBRARY_PATH` environment variables, so
  # it can work out of the box:
  #
  #  - https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/programs/nix-ld.nix#L37-L40
  #
  # You can overwrite `NIX_LD_LIBRARY_PATH` in the environment where you run the non-NixOS binaries to customize the
  # search path for shared libraries.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };
}
