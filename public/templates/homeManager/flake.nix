{
  description = "Your new nix config";

  /*
  * Inputs is an attribute set that defines all the dependencies of this flake.
  * These dependencies will be passed as arguments to the outputs function after they are fetched
  * Inputs can be :- another flake, a regular Git repository, or a local path
  */
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    akibOS.url = "github:akibahmed229/nixos";
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
    system = "x86_64-linux";
    # FIXME: Replace with your username
    user = "akib";

    pkgs = import nixpkgs {
      inherit system;
      config = {allowUnfree = true;};
    };

    mkHomeManagerSystem = akibOS.lib.mkSystem {
      # must pass this args to mkSystem
      inherit (nixpkgs) lib;
      inherit pkgs home-manager;
      homeConf = true;

      # Set all inputs parameters as special arguments for all submodules,
      # so you can directly use all dependencies in inputs in submodules
      specialArgs = {inherit inputs self user;}; # pass args as your requirement (make sure to pass user)
    };
  in {
    # home-manager options:- https://home-manager-options.extranix.com/

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = mkHomeManagerSystem ./home;
  };
}
