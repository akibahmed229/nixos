# in nix repl by running the following command you cal import the flake
# nix-repl> :lf .
{
  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/nixos-23.11";};
    unstable = {url = "github:nixos/nixpkgs/nixos-unstable";};
    snowfall-lib = {url = "github:snowfallorg/lib";};
  };

  # inputs@{...} is a shorthand for { inputs = inputs; ... }
  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;

      src = ./.; # use the current directory as the source
    };
}
