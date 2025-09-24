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
  forAllSystems = lib.genAttrs ["aarch64-linux" "i686-linux" "x86_64-linux"];

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
  processDirNixOS = mapAttrs' (name: value:
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
    })
  (getHosts path);

  # Function to process directories for Home Manager systems
  # This function now correctly scans the nested directory structure
  processDirHomeManager = let
    # 1. Get all architecture directories like { "x86_64-linux" = "directory"; ... }
    archDirs = getHosts path;

    # 2. For each architecture, find the home-manager configs inside.
    listOfConfigs =
      lib.attrsets.mapAttrsToList (
        archName: archValue:
        # Only process directories & Valid system architectures
          if !(builtins.hasAttr archName (forAllSystems (system: system)))
          then throw "Invalid system architecture type!!!: ${archName}"
          else if !(isDirectory archValue)
          then {}
          else let
            # Get all home-manager host entries in the architecture directory first...
            allEntriesInArch = getHosts (path + "/${archName}");

            # ...then filter this set to keep ONLY the directories.
            hostDirsInArch = lib.attrsets.filterAttrs (name: value: isDirectory value) allEntriesInArch;
          in
            lib.mapAttrs' (hostName: hostValue: {
              name = hostName;
              # Import Home-Manager Configuration
              value = homeManagerConfiguration {
                pkgs = import nixpkgs {
                  system = archName; # Use the architecture from the parent directory
                  config = {allowUnfree = true;};
                };
                extraSpecialArgs = specialArgs // {hostname = hostName;};
                modules = map ifFileExists [
                  (path + "/${archName}/home.nix") # Base config for this architecture
                  (path + "/${archName}/${hostName}") # Host-specific config
                ];
              };
            })
            hostDirsInArch
      )
      archDirs;
  in
    # 3. Merge the list of attribute sets from all architectures into one big set.
    lib.foldl lib.recursiveUpdate {} listOfConfigs;

  # Function to process directories for Nix-on-Droid systems
  processDirNixOnDroid = mapAttrs' (name: value:
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
    })
  (getHosts path);

  # Function to process template directories
  processDirTemplate = mapAttrs' (name: value:
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
    })
  (getHosts path);

  # Process directory contents based on the type of system being configured
  # Check if we are processing Home Manager, Nix-on-Droid, or NixOS systems
  processed =
    if homeConf
    then processDirHomeManager
    else if droidConf
    then processDirNixOnDroid
    else if template
    then processDirTemplate
    # Default to NixOS
    else processDirNixOS;

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
