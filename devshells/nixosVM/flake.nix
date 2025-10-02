{
  description = "A flake app that runs a NixOS VM demo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    akibLibSrc = {
      url = "github:akibahmed229/nixos";
      flake = false; # Keeps the dependency graph small, as intended
    };
  };

  outputs = {
    self,
    nixpkgs,
    akibLibSrc,
  }: let
    lib = nixpkgs.lib;
    akibLib = import "${akibLibSrc}/lib" {inherit lib;};
    inherit (akibLib) forAllSystems; # Extract the helper function
  in {
    # (Optional) Also expose the VM build itself as a package.
    # To use: `nix run .#`
    packages = forAllSystems (system: let
      # 1. Build the NixOS VM configuration from our module.
      # This evaluates `vm.nix` and creates a full system definition.
      nixosVM = nixpkgs.lib.nixosSystem {
        inherit system;
        pkgs = import nixpkgs {inherit system;};
        modules = [./vm.nix];
      };
    in {
      default = nixosVM.config.system.build.vm;
    });
  };
}
