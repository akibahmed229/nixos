{ pkgs, ... };

pkgs.writeShellScriptBin "update-input" ''
          input=$(                                           \
            nix flake metadata --json                        \
            | ${pkgs.jq}/bin/jq ".locks.nodes.root.inputs[]" \
            | sed "s/\"//g"                                  \
            | ${pkgs.fzf}/bin/fzf)
          nix flake lock --update-input $input
'';
