{pkgs ? import <nixpkgs> {}}:
# sudo nix run <path/to/flake.nix>/ # to update the input of a flake
pkgs.writeShellApplication {
  name = "update-input";
  text = ''
    input=$(${pkgs.jq}/bin/jq -r ".nodes.root.inputs | keys[]" < flake.lock | ${pkgs.fzf}/bin/fzf)
    nix flake lock --update-input "$input"
  '';
}
