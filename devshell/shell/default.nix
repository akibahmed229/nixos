# where all the possible development environments are defined 

{system, pkgs, inputs,... }:

{
  python = import ./python/python.nix { inherit system pkgs inputs; };

  nodejs = import ./nodejs/nodejs.nix { inherit pkgs; };

  gtk3_env = import ./c_c++/gtk3_env.nix {inherit pkgs; };
}
