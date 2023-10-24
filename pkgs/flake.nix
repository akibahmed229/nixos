#  Can be run with "$ nix build" or "$ nix build </path/to/flake.nix>#<host>"
{
  description = "hello-world flake";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    lib = nixpkgs.lib;
  in
  {
    packages.${system} = (
    import ./custompkgs { 
      inherit lib pkgs; 
    });
  };
}
