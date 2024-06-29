# in nix repl by running the following command you cal import the flake
# nix-repl> :lf .
{
  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/nixos-23.11";};
    unstable = {url = "github:nixos/nixpkgs/nixos-unstable";};

    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
    };
  };

  # inputs@{...} is a shorthand for { inputs = inputs; ... }
  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils-plus,
    ...
  }:
    flake-utils-plus.lib.mkFlake rec {
      inherit inputs self;

      outputsBuilder = channels: {
        packages = {
          inherit (channels.unstable) hello;
        };
      };
    };
}
