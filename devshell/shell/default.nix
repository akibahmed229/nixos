# where all the possible development environments are defined 

{ system, pkgs, inputs, unstable, ... }:

{
  python = import ./python/python.nix { inherit system pkgs unstable inputs; };

  nodejs = import ./nodejs/nodejs.nix { inherit pkgs; };

  gtk3_env = import ./c_c++/gtk3_env.nix { inherit pkgs; };
}
