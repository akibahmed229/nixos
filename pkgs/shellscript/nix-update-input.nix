{ pkgs ? import <nixpkgs> { } }:

# sudo nix run <path/to/flake.nix>/ # to update the input of a flake
pkgs.writeShellScriptBin "update-input" ''
  input=$(${pkgs.jq}/bin/jq ".nodes.root.inputs | keys[]" < flake.lock \
          | awk -F "\"" '{print $2}' \
          | ${pkgs.fzf}/bin/fzf)

  nix flake lock --update-input $input
''
