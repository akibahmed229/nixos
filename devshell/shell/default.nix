# where all the possible development environments are defined 

{ system, pkg, inputs, pkg-unstable, ... }:
let
  pkgs = pkg.${system};
  unstable = pkg-unstable.${system};
in
{
  python = import ./python/python.nix { inherit system pkgs unstable inputs; };

  nodejs = import ./nodejs/nodejs.nix { inherit pkgs; };

  gtk3_env = import ./c_c++/gtk3_env.nix { inherit pkgs; };
  
  kernel-build-env = import ./kernel-build-env/kernel-build-env.nix { inherit pkgs; };
}
