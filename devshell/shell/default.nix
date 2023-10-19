{pkgs, ... }:

{
  python = import ./python/python.nix { inherit pkgs; };

  nodejs = import ./nodejs/nodejs.nix { inherit pkgs; };
}
