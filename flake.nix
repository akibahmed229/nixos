{
  description = "Akib | NixOS Configuration Go Wild";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      "https://nix-community.cachix.org"
      # "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  /*
  * Inputs is an attribute set that defines all the dependencies of this flake.
  * These dependencies will be passed as arguments to the outputs function after they are fetched
  * Inputs can be :- another flake, a regular Git repository, or a local path

  * Version Pinning in Nix Flakes (GitHub/GitLab/Git)
      - ?ref=<tag> → use a specific tag (e.g., ?ref=v1.2.3)
      - &ref=refs/tags/<version> → explicitly reference a tag ref
      - &rev=<hash> → pin to an exact commit
      - &shallow=1 → fetch a shallow clone (faster, truncated history)

  * Symbols
      - ? → starts query parameters in a URL
      - & → separates multiple parameters
  */
  inputs = {
    ####################  Core Repositories ####################
    # Between nixpkgs-unstable and master is about 3 days and a binary cache And then like 1-2 more days till nixos-unstable
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    # Home Manager is a Nix-powered tool for reproducible management of the contents of users’ home directories
    home-manager = {
      url = "github:nix-community/home-manager/master?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Manage your macOS using Nix
    darwin = {
      url = "github:nix-darwin/nix-darwin/master?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-on-droid is a project to run Nix on Android
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/master?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ####################  Desktop Environments & WindowManager | remote flake ####################
    # Hyprland is a collection of NixOS modules and packages for a more modern and minimal desktop experience. with plugins for home-manager.
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1&ref=refs/tags/v0.52.1"; # NOTE: if new version release update the tags
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ####################  Community & Other Repositories | remote flake ####################
    # nix-index is a tool to quickly locate the package providing a certain file in nixpkgs. It indexes built derivations found in binary caches.
    nix-index-database = {
      url = "github:Mic92/nix-index-database?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Handle persistent state on systems with ephemeral root storage
    impermanence = {
      url = "github:nix-community/impermanence?shallow=1";
    };
    # Nix User Repository: User contributed nix packages
    nur = {
      url = "github:nix-community/NUR?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Secret management for nixos
    sops-nix = {
      url = "github:Mic92/sops-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Stylix is a NixOS module which applies the same colour scheme, font and wallpaper to a range of applications and desktop environments.
    stylix = {
      url = "github:danth/stylix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Flexible toolkit for making desktop shells with QtQuick, for Wayland and X11
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Modifies Spotify using spicetify-cli. spicetify-themes are included and available.
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #################### Personal Repositories | local flake ####################
    # Private secrets repo. Authenticate via ssh and use shallow clone
    secrets = {
      url = "git+ssh://git@gitlab.com/akibahmed/sops-secrects.git?ref=main&shallow=1";
      flake = false;
    };
  };

  /*
  * outputs is a function that takes the dependencies from inputs as its parameters,
  * and its return value is an attribute set, which represents the build results of the flake.
  * outputs section defines the different outputs that a flake can produce during its build process
  */
  outputs = {
    self, # The special input named self refers to the outputs and source tree of this flake
    nixpkgs,
    home-manager,
    darwin,
    nix-on-droid,
    ...
    # inputs@ is a shorthand for passing the inputs attribute into the outputs parameters
  } @ inputs: let
    # The system to build.
    inherit (nixpkgs) lib;
    state-version = "25.11";

    # The user to build for.
    # Override user via env var in impure mode
    user = "akib";
    theme = "gruvbox-dark-soft"; # available options located in ./public/themes/base16Scheme
    desktopEnvironment = "niri"; # available options: "gnome", "dwm", "hyprland"

    # Custom library of helper functions
    myLib = import ./lib {inherit lib;};
    inherit (myLib) mkFlake mkSystem;
  in
    # The function to generate the system configurations (derived from my custom lib helper function)
    mkFlake {inherit self inputs;} {
      src = ./.;
      mkNixOSSystem = mkSystem {
        inherit nixpkgs home-manager;
        specialArgs = {inherit inputs self user desktopEnvironment theme state-version;};
      };
      mkHomeManagerSystem = mkSystem {
        inherit nixpkgs home-manager;
        homeConf = true;
        specialArgs = {inherit inputs self user theme state-version;};
      };
      mkNixDarwinSystem = mkSystem {
        inherit nixpkgs darwin home-manager;
        darwinConf = true;
        specialArgs = {inherit inputs self user theme state-version;};
      };
      mkNixOnDroidSystem = mkSystem {
        inherit nixpkgs home-manager nix-on-droid;
        droidConf = true;
        specialArgs = {inherit inputs self user state-version;};
      };
    };
}
