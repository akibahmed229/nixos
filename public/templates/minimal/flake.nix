{
  description = "Minimal Nixos Install";

  /*
  * Inputs is an attribute set that defines all the dependencies of this flake.
  * These dependencies will be passed as arguments to the outputs function after they are fetched
  * Inputs can be :- another flake, a regular Git repository, or a local path
  */
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    akibOS = {
      url = "github:akibahmed229/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  /*
  * outputs is a function that takes the dependencies from inputs as its parameters,
  * and its return value is an attribute set, which represents the build results of the flake.
  * outputs section defines the different outputs that a flake can produce during its build process
  * Following :- devshells, packages, formatter, overlays, nixosModules, homeManagerModules, nixosConfigurations, darwinConfigurations, homeConfigurations (Standalone setup) etc
  */
  outputs = {
    self, # The special input named self refers to the outputs and source tree of this flake
    nixpkgs,
    home-manager,
    akibOS,
    ...
  } @ inputs: let
    # FIXME: Replace with your username
    user = "test";
    state-version = "25.11";
    devicename = "/dev/nvme1n1";

    # The function to generate the nixos system configuration for the supported systems only (derived from my custom lib helper function)
    mkNixOSSystem = akibOS.lib.mkSystem {
      # must pass this args to mkSystem
      inherit nixpkgs home-manager;

      # Set all inputs parameters as special arguments for all submodules,
      # so you can directly use all dependencies in inputs in submodules
      specialArgs = {inherit inputs self user state-version devicename;}; # pass args as your requirement (make sure to pass user)
    };
  in {
    # nixpkgs search:- https://search.nixos.org/packages
    # nixos options:- https://search.nixos.org/options?
    # home-manager options:- https://home-manager-options.extranix.com/

    # NixOS configuration entrypoint ( flake & home-manager as module)
    # Accessible through "$ nixos-rebuild switch --flake .#host"
    # in our case .#host with directory located in the mentioned path ./hosts
    nixosConfigurations = mkNixOSSystem ./hosts;
  };
}
