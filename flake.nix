{
  description = "Akib | NixOS Configuration Go Wild";

  /*
  * the nixConfig here only affects the flake itself, not the system configuration!
  * for more information, see:
      - https://nixos-and-flakes.thiscute.world/nixos-with-flakes/add-custom-cache-servers
  */
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  /*
  * Inputs is an attribute set that defines all the dependencies of this flake.
  * These dependencies will be passed as arguments to the outputs function after they are fetched
  * Inputs can be :- another flake, a regular Git repository, or a local path
  */
  inputs = {
    # stable packages
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    # unstable packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/?ref=nixpkgs-unstable";

    # live image builder for nixos
    nixos.url = "github:nixos/nixpkgs/24.05";
    # nix-index is a tool to quickly locate the package providing a certain file in nixpkgs. It indexes built derivations found in binary caches.
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # stable home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # unstable home-manager
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Hyprland is a collection of NixOS modules and packages for a more modern and minimal desktop experience. with plugins for home-manager.
    # Add "inputs.hyprland.homeManagerModules.default" to home-config
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    # KDE Plasma User Settings Generator
    # Add "inputs.plasma-manager.homeManagerModules.plasma-manager" to home-config
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "nixpkgs";
    };

    # Declarative disk partitioning and formatting using nix
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Handle persistent state on systems with ephemeral root storage
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    # Firefox-addons is a collection of Firefox extensions
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Modifies Spotify using spicetify-cli. spicetify-themes are included and available.
    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Secret management for nixos
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    # Stylix is a NixOS module which applies the same colour scheme, font and wallpaper to a range of applications and desktop environments.
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "nixpkgs";
    };
    #  A customizable and extensible shell
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # nixvim is a nix flake that provides a vim configuration with plugins and themes managed by nix
    nixvim = {
      url = "git+file:.?dir=/pkgs/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # My devShells for different systems
    my-devShells = {
      url = "git+file:.?dir=/devshells";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
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
    nixpkgs-unstable,
    home-manager,
    my-devShells,
    ...
    # inputs@ is a shorthand for passing the inputs attribute into the outputs parameters
  } @ inputs: let
    # The system to build.
    inherit (nixpkgs) lib;
    state-version = "24.05";
    hostname = "desktop";
    devicename = "/dev/nvme0n1";

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
    forAllSystems = lib.genAttrs systems;

    # The user to build for.
    user = "akib";
    theme = "gruvbox-dark-soft";
    desktopEnvironment = "hyprland"; # available options: "gnome", "kde", "dwm", "hyprland"

    # Dynamically get the current system and pass it to the nixpkgs
    pkgs = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config = {allowUnfree = true;};
      });
    # The unstable nixpkgs can be used [ e.g., unstable.${pkgs.system} ]
    unstable = forAllSystems (system:
      import nixpkgs-unstable {
        inherit system;
        config = {allowUnfree = true;};
      });

    # The function to generate the nixos system configuration for the supported systems only (derived from my custom lib helper function)
    mkNixOSSystem = let
      system = forAllSystems (system:
        if
          builtins.elem system [
            "aarch64-linux" # ARM (Raspberry Pi)
            "x86_64-linux" # x86_64 (Intel/AMD) 64-bit
            "i686-linux" # x86 (Intel/AMD) 32-bit
          ]
        then system
        else throw "Unsupported system: ${system}");
    in
      self.lib.mkNixOSSystem {
        inherit (nixpkgs) lib;
        inherit pkgs system home-manager;
        specialArgs = {inherit inputs self unstable user hostname devicename desktopEnvironment theme state-version;};
      };
    # using the above variables,function, etc. to generate the system configuration
  in {
    # Accessible through 'nix develop" etc
    inherit (my-devShells) devShells;
    # lib is a custom library of helper functions
    lib = import ./lib;
    # Accessible through 'nix build', 'nix shell', "nix run", etc
    packages = forAllSystems (
      system:
      # Import your custom packages
        import ./pkgs nixpkgs.legacyPackages.${system}
        # import custom nixvim flake as a package
        // {
          nixvim = inputs.nixvim.packages.${system}.default;
        }
    );
    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/custom/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/custom/home-manager;
    # NixOS configuration with flake and home-manager as module
    # Accessible through "$ nixos-rebuild switch --flake </path/to/flake.nix>#<host>"
    nixosConfigurations = mkNixOSSystem ./hosts;
  };
}
