{ pkgs ? import <nixpkgs> {}}:

  pkgs.mkShell {
  name = "C/C++ GTK 3 development environment";
  packages = [  
    ];
    
  nativeBuildInputs = with pkgs; [
     gtk3
     pkg-config
     cmake
     clang-tools
  ];

  shellHook = ''
    echo "Welcome to the C/C++ GTK 3 development environment."
    export LD_LIBRARY_PATH=${pkgs.gtk3}/lib:$LD_LIBRARY_PATH
  '';

  }


