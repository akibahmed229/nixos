{pkgs ? import <nixpkgs> {}}:
# sudo nix run <path/to/flake.nix>/ # to update the input of a flake
pkgs.writeShellApplication {
  name = "hello";
  text = ''
    echo "Hello, world!"
  '';
}
