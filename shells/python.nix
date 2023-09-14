{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "python-env";
  
  buildInputs = [
    pkgs.python311
    pkgs.python311Packages.pygame
  ];
  
  shellHook = ''
    venv="$(cd $(dirname $(which python)); cd ..; pwd)"
    ln -Tsf "$venv" .venv
  '';
}

