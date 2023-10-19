{pkgs, ... }:

{
  python = imports = [ ./python.nix ];

  nodejs = {
    imports = [ ./nodejs.nix ];
    inherit pkgs;
  };
}
