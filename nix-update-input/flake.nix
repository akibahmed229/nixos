# sudo nix run <path/to/flake.nix>/ # to update the input of a flake
{
  description = "This will update the input of a flake for each input.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ]
          (system: function nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.writeShellScriptBin "update-input" ''
          input=$(                                           \
            nix flake metadata --json                        \
            | ${pkgs.jq}/bin/jq ".locks.nodes.root.inputs[]" \
            | sed "s/\"//g"                                  \
            | ${pkgs.fzf}/bin/fzf)
          nix flake lock --update-input $input
        '';
      });
    };
}
