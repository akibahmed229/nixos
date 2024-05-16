# where all the possible development environments are defined 

# Direnv is a tool that allows you to define environment variables in a .envrc file in a directory and have them automatically loaded when you cd into that directory.
# Go to your desired dir and run the following commands
# echo 'use flake github:akibahmed229/nixos"devShell_name"' > .envrc
# direnv allow 

{ system, pkg, inputs, pkg-unstable, ... }:
let
  pkgs = pkg.${system};
  unstable = pkg-unstable.${system};
in
{
  kernel_build_env = import ./kernel-build-env/kernel-build-env.nix { inherit pkgs; };

  python = import ./python/python.nix { inherit system pkgs unstable inputs; };
  jupyter = import ./python/jupyter.nix { inherit system pkgs unstable inputs; };

  nodejs = import ./nodejs/nodejs.nix { inherit pkgs; };

  gtk3_env = import ./c_c++/gtk3_env.nix { inherit pkgs; };
}
