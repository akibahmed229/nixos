{ pkgs ? import <nixpkgs> {} }:

let
  pythonEnv = import ./python.nix { inherit pkgs; };
in

pkgs.mkShell {
  # Your shell configuration here

  # Include the Python environment as a build input
  buildInputs = with pkgs; [ pythonEnv ];

  # Set the shellHook from pythonEnv
  shellHook = pythonEnv.shellHook;
}

