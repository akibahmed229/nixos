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
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  /*
  * Inputs is an attribute set that defines all the dependencies of this flake.
  * These dependencies will be passed as arguments to the outputs function after they are fetched
  * Inputs can be :- another flake, a regular Git repository, or a local path
  */
  inputs = {
    ####################  Core Repositories ####################

    # Nixpkgs is a collection of over 100,000 software packages that can be installed with the Nix package manager. It also implements NixOS, a purely-functional Linux distribution.
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/?ref=nixpkgs-unstable";
    # Home Manager is a Nix-powered tool for reproducible management of the contents of users’ home directories
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # nix-on-droid is a project to run Nix on Android
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    ####################  Desktop Environments & WindowManager | remote flake ####################

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

    ####################  Community & Other Repositories | remote flake ####################

    # nix-index is a tool to quickly locate the package providing a certain file in nixpkgs. It indexes built derivations found in binary caches.
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
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
    # A customizable and extensible shell
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    #################### Personal Repositories | local flake ####################

    # Modifies Spotify using spicetify-cli. spicetify-themes are included and available.
    spicetify-nix = {
      url = "github:akibahmed229/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixvim is a nix flake that provides a vim configuration with plugins and themes managed by nix
    nixvim = {
      url = "path:./pkgs/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # My devShells for different systems
    my-devShells = {
      url = "path:./devshells";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
    # Private secrets repo. Authenticate via ssh and use shallow clone
    mySsecrets = {
      url = "git+ssh://git@gitlab.com/akibahmed/sops-secrects.git";
      flake = false;
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
    nix-on-droid,
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
    forAllSystems = lib.genAttrs ["aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];

    # The user to build for.
    user =
      if (builtins.toString (builtins.getEnv "ISITYOU") == "yes")
      then "test"
      else "akib";
    theme = "gruvbox-dark-soft"; # available options located in ./public/themes/gtk, directory name is the theme name
    desktopEnvironment = "hyprland"; # available options: "gnome", "kde", "dwm", "hyprland"

    # The unstable nixpkgs can be used [ e.g., unstable.${pkgs.system} ]
    unstable = forAllSystems (system:
      import nixpkgs-unstable {
        inherit system;
        config = {allowUnfree = true;};
      });

    # The function to generate the system configurations (derived from my custom lib helper function)
    inherit (self.lib) mkSystem mkDerivation mkOverlay mkModule;
    mkNixOSSystem = mkSystem {
      inherit nixpkgs home-manager;
      system = forAllSystems (s: s);
      specialArgs = {inherit inputs self unstable user hostname devicename desktopEnvironment theme state-version;};
    };
    mkHomeManagerSystem = mkSystem {
      inherit nixpkgs home-manager;
      homeConf = true;
      specialArgs = {inherit inputs self unstable user theme state-version;};
    };
    mkNixOnDroidSystem = mkSystem {
      inherit nixpkgs home-manager nix-on-droid;
      droidConf = true;
      specialArgs = {inherit inputs self unstable user state-version;};
    };
    mkTemplate = mkSystem {
      inherit nixpkgs;
      template = true;
    };
  in {
    inherit (my-devShells) devShells; # available through "$ nix develop .#devShells"
    lib = import ./lib {inherit lib;}; # Lib is a custom library of helper functions

    # Accessible through 'nix build', 'nix shell', "nix run", etc
    packages = forAllSystems (
      system:
        mkDerivation {
          inherit nixpkgs system;
          path = ./pkgs;
        }
        // {nixvim = inputs.nixvim.packages.${system}.default;}
    );

    # Your custom packages and modifications, exported as overlays
    overlays = mkOverlay {
      inherit inputs;
      path = ./overlays;
    };
    # available through 'nix fmt'. option: "alejandra" or "nixpkgs-fmt"
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra or {});

    # Reusable nixos & home-manager modules you might want to export
    nixosModules = mkModule ./modules/custom/nixos;
    homeManagerModules = mkModule ./modules/custom/home-manager;

    # The nixos system configurations for the supported systems
    nixosConfigurations = mkNixOSSystem ./hosts/nixos; # available through "$ nixos-rebuild switch --flake .#host"
    homeConfigurations = mkHomeManagerSystem ./hosts/homeManager; # available through "$ home-manager switch --flake .#home"
    nixOnDroidConfigurations = mkNixOnDroidSystem ./hosts/nixOnDroid; # available through "$ nix-on-droid switch --flake .#device"
    templates = mkTemplate ./public/templates; # available through "$ nix flake init -t .#template"
  };
}
