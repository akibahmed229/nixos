{ pkgs ? import <nixpkgs> {}}:

# sudo nix run <path/to/flake.nix>/ # to update the input of a flake
pkgs.writeShellScriptBin "update-input" ''
  input=$(                                           \
            nix flake metadata --json                        \
            | ${pkgs.jq}/bin/jq ".locks.nodes.root.inputs | keys[]" \
            | sed "s/\"//g"                                  \
            | ${pkgs.fzf}/bin/fzf)
          nix flake lock --update-input $input
''
