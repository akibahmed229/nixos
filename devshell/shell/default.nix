{system, pkgs, inputs,... }:

{
  python = import ./python/python.nix { inherit system pkgs inputs; };

  nodejs = import ./nodejs/nodejs.nix { inherit system pkgs inputs; };
}
