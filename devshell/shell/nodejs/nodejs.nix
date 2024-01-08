{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  name = "nodejs-dev-environment";
  nativeBuildInputs = with pkgs; [
    nodejs-14_x # Replace with the Node.js version you want
    yarn # You can use npm instead if you prefer
  ];
  shellHook = ''
    export NODE_ENV=development
  '';
}


