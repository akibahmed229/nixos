{ pkgs ? import <nixpkgs> {} }:

  pkgs.mkShell {
    packages = [  
       (pkgs.python311.withPackages (python-pkgs: [
          python-pkgs.pygame
     ]))
    ];

  # Workaround: make vscode's python extension read the .venv
  shellHook = ''
    venv="$(cd $(dirname $(which python)); cd ..; pwd)"
    ln -Tsf "$venv" .venv
  '';
    # ...
  }

