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

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
    nix-on-droid,
    ...
  } @ inputs: let
    # This function generates the nix-on-droid system configuration for Android devices
    mkNixOnDroidSystem = akibOS.lib.mkSystem {
      # must pass this args to mkSystem
      inherit nixpkgs home-manager nix-on-droid;
      droidConf = true;

      # Set all inputs parameters as special arguments for all submodules,
      # so you can directly use all dependencies in inputs in submodules
      specialArgs = {inherit inputs self;}; # pass args as your requirement
    };
  in {
    # nix-on-droid options:- https://nix-community.github.io/nix-on-droid/
    # home-manager options:- https://home-manager-options.extranix.com/

    # Nix-On-Droid configuration entrypoint for Android (flake & home-manager as module)
    # Accessible through "$ nix-on-droid switch --flake path/to/flake#device"
    nixOnDroidConfigurations = mkNixOnDroidSystem ./hosts;
  };
}
