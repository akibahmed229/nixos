/*
* Imports and Dependencies: The script imports various libraries and configurations such as nixpkgs, home-manager, and nix-on-droid.
* These imports are used to define and manage NixOS, Home Manager, and Nix-on-Droid systems.

* Processing Functions: The processDirNixOS, processDirHome, processDirNixOnDroid, and processDirTemplate functions are defined to handle different types of systems.
* Each function checks if the input is a directory and then processes it accordingly.

* Conditional Mapping: The processed attribute uses mapAttrs' to apply the correct processing function based on the flags (homeConf, droidConf, template).

* Filtering: Non-directory entries are filtered out using filterAttrs, and the valid attributes are converted to a list of attribute sets.

* Error Handling: The script checks if the processed list is empty and throws an error if no systems are found.

* Final Output: The script returns the final list of valid systems using builtins.listToAttrs.
*/
{
  # Default arguments for the function
  system ? "x86_64-linux", # Default system architecture
  nixpkgs ? {},
  template ? false,
  homeConf ? false,
  droidConf ? false,
  specialArgs ? {},
  home-manager ? {},
  nix-on-droid ? {},
  ...
}: path: let
  # Importing necessary functions and utilities from the provided imports
  inherit (nixpkgs) lib;
  inherit (builtins) readDir trace;
  inherit (nix-on-droid.lib) nixOnDroidConfiguration;
  inherit (home-manager.lib) homeManagerConfiguration;
  inherit (lib) nixosSystem strings attrsets mapAttrs' nameValuePair pathExists mkDefault optionals filterAttrs attrNames lists concatStringsSep;

  # Supported systems for your flake packages, shell, etc.
  forAllSystems = lib.genAttrs ["aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];

  eachPkgs = import nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };

  # Utility to check if a given path points to a directory
  isDirectory = attr: attr == "directory";
  # Utility to check if a given path is a Nix file
  isNixFile = name: strings.hasSuffix ".nix" name;

  # Read directory contents from the provided path
  getHosts = path: let
    contents = readDir path;
  in
    # Keep only directories with a default.nix file and nix files themselves
    attrsets.filterAttrs (
      name: attr:
        isDirectory attr || (isNixFile name && name != "default.nix")
    )
    contents;

  # Function to check if a file exists at the specified path
  ifFileExists = _path:
    if pathExists _path
    then _path
    else throw "File not found: ${_path}";

  # Function to process directories for NixOS systems
  processDirNixOS = name: value:
    if isDirectory value
    then {
      inherit name;
      # Import NixOS system configuration
      value = nixosSystem {
        system = forAllSystems (system: system);
        specialArgs =
          (mapAttrs' (n: v: nameValuePair n v) specialArgs)
          // {
            system = {inherit name path;};
          };
        modules =
          map ifFileExists [
            (path + "/configuration.nix") # Base configuration
            (path + "/${name}/hardware-configuration.nix") # Host-specific hardware configuration
            (path + "/${name}") # Host-specific configuration
          ]
          ++
          # Include Home Manager configuration if the system is integrated
          optionals (home-manager != {})
          [
            home-manager.nixosModules.home-manager # Home Manager integration

            {
              home-manager = {
                backupFileExtension = "hm-bak"; # Set backup file extension
                useGlobalPkgs = mkDefault true;
                useUserPackages = mkDefault true;
                extraSpecialArgs = mapAttrs' (n: v: nameValuePair n v) specialArgs;
              };
            }
          ];
      };
    }
    else {
      inherit name value;
    };

  # Function to process directories for Home Manager systems
  processDirHome = name: value:
    if isDirectory value
    then {
      inherit name;
      # Import Home Manager configuration
      value = homeManagerConfiguration {
        pkgs = eachPkgs;
        extraSpecialArgs =
          mapAttrs' (n: v: nameValuePair n v) specialArgs
          // {hostname = name;};
        modules = map ifFileExists [
          (path + "/home.nix") # Base Home Manager configuration
          (path + "/${name}") # Host-specific configuration
        ];
      };
    }
    else {
      inherit name value;
    };

  # Function to process directories for Nix-on-Droid systems
  processDirNixOnDroid = name: value:
    if isDirectory value
    then {
      inherit name;
      # Import Nix-on-Droid system configuration
      value = nixOnDroidConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux"; # System architecture for Android
          overlays = [
            nix-on-droid.overlays.default # Apply default overlays
            # add other overlays if needed
          ];
        };
        extraSpecialArgs = mapAttrs' (n: v: nameValuePair n v) specialArgs;
        modules =
          map ifFileExists [
            (path + "/configuration.nix") # Base configuration
            (path + "/${name}") # Host-specific configuration
          ]
          ++ [
            {
              home-manager = {
                backupFileExtension = "hm-bak"; # Set backup file extension
                useGlobalPkgs = true; # Use global packages
                extraSpecialArgs = mapAttrs' (n: v: nameValuePair n v) specialArgs;
              };
            }
          ];
        # Set path to Home Manager flake
        home-manager-path = home-manager.outPath;
      };
    }
    else {
      inherit name value;
    };

  # Function to process template directories
  processDirTemplate = name: value:
    if isDirectory value
    then {
      inherit name;
      # Import template configuration
      value = {
        description = "Template for ${name} system";
        # Set path to the template
        path = ifFileExists (path + "/${name}");
      };
    }
    else {
      inherit name value;
    };

  # Process directory contents based on the type of system being configured
  processed =
    mapAttrs' (
      # Check if we are processing Home Manager, Nix-on-Droid, or NixOS systems
      if homeConf
      then processDirHome
      else if droidConf
      then processDirNixOnDroid
      else if template
      then processDirTemplate
      else processDirNixOS # Default to NixOS
    )
    (getHosts path);

  # Filter out non-directory entries from the processed list
  validAttrs = filterAttrs (_: v: v != "regular" && v != "symlink" && v != "unknown") processed;

  # Convert the filtered attributes to a list of attribute sets
  validList = map (name: {
    inherit name;
    value = validAttrs.${name};
  }) (attrNames validAttrs);

  # Concatenate the names of the found hosts for logging purposes
  foundHosts = concatStringsSep ", " (attrNames validAttrs);

  # Check if the directory is empty and throw an error if no systems are found
  isHostsEmpty = _:
    if lists.length validList == 0
    then throw "No systems found in ${path}"
    else trace "systems found in: ${path}\navailable systems: ${foundHosts}" _;
  # Return the final list of valid systems
in
  isHostsEmpty builtins.listToAttrs validList
