{
  description = "Akib | NixOS Configuration";

  # inputs for the flake
  inputs = {
    # stable packages
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    # unstable packages 
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # live image builder for nixos
    nixos.url = "github:nixos/nixpkgs/23.11-beta";
    # nix-index is a tool to quickly locate the package providing a certain file in nixpkgs. It indexes built derivations found in binary caches.
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # stable home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # unstable home-manager
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland is a collection of NixOS modules and packages for a more modern and minimal desktop experience. with plugins for home-manager.
    # Add "hyprland.nixosModules.default" to the host moduls list in ./hosts/default.nix
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    # Add "inputs.plasma-manager.homeManagerModules.plasma-manager" to the home-manager.users.${user}.imports list in ./hosts/default.nix
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "nixpkgs";
    };

    # firefox-addons is a collection of Firefox extensions
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Modifies Spotify using spicetify-cli. spicetify-themes are included and available.
    spicetify-nix.url = "github:the-argus/spicetify-nix";
    # secret management for nixos
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # outputs for the flake
  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos
    , nix-index-database
    , home-manager
    , hyprland
    , plasma-manager
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      # The system to build.
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
      state-version = "23.11";

      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # The user to build for.
      user = "akib";
      theme = "gruvbox-dark-soft";

      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };

      unstable = import nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
      };

      # using the above variables to define the system configuration
    in
    {
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (getSystem: import ./pkgs nixpkgs.legacyPackages.${getSystem});

      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (getSystem: nixpkgs.legacyPackages.${getSystem}.nixpkgs-fmt);

      # NixOS configuration with flake and home-manager as module
      #  Accessible through "$ nixos-rebuild switch --flake .#<host> " or "$ nixos-rebuild switch --flake </path/to/flake.nix>#<host>"
      #  Accessible through github "$ nixos-install --flake github:akibahmed229/nixos/#<host>
      nixosConfigurations = import ./hosts {
        inherit (nixpkgs) lib;
        inherit inputs unstable nixos user system theme state-version nix-index-database home-manager hyprland plasma-manager; # Also inherit home-manager so it does not need to be defined here.
      };
    };
}
