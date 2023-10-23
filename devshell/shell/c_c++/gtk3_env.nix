{system, pkgs ? import <nixpkgs> {}, inputs }:

  pkgs.mkShell {
  name = "C/C++ GTK 3 development environment";
  packages = [  
    ];
    
  nativeBuildInputs = with pkgs; [
     gtk3
  ];

  # Workaround: make vscode's python extension read the .venv
  shellHook = ''
      echo "Welcome to the C/C++ GTK 3 development environment"
  '';
  }


