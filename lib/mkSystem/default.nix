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
{myUtils}: {
  # Default arguments for the function
  nixpkgs ? {},
  home-manager ? {},
  darwin ? {},
  nix-on-droid ? {},
  specialArgs ? {},
  homeConf ? false,
  darwinConf ? false,
  droidConf ? false,
  template ? false,
  ...
}: path: let
  # Importing necessary functions and utilities from the provided imports
  inherit
    (nixpkgs)
    lib
    ;
  inherit
    (builtins)
    trace
    ;
  inherit
    (nix-on-droid.lib)
    nixOnDroidConfiguration
    ;
  inherit
    (home-manager.lib)
    homeManagerConfiguration
    ;
  inherit
    (darwin.lib)
    darwinSystem
    ;
  inherit
    (lib)
    nixosSystem
    mapAttrs'
    optionals
    filterAttrs
    attrNames
    lists
    concatStringsSep
    ;
  inherit
    (myUtils)
    isDirectory
    getEntries
    ifFileExists
    forAllSystems
    ;

  # ── 1. Generic Directory Processor ───────────────────────────────────────────
  # This new function contains all the shared logic for iterating through
  # architectures and hosts. It takes a `mkConfig` function as an argument
  # to handle the parts that are different.
  processDir = {
    validSystems ? (forAllSystems (system: system)),
    mkConfig,
  }: let
    # Get all architecture directories like { "x86_64-linux" = "directory"; ... }
    archDirs = getEntries path;

    # For each architecture, find the configs inside.
    listOfConfigs =
      lib.attrsets.mapAttrsToList (
        archName: archValue:
        # Only process directories & valid system architectures
          if !(builtins.hasAttr archName validSystems)
          then throw "Invalid or unsupported system architecture type for this configuration: ${archName}"
          else if !(isDirectory archValue)
          then {}
          else let
            # Get all host entries in the architecture directory first...
            allEntriesInArch = getEntries (path + "/${archName}");

            # ...then filter this set to keep ONLY the directories.
            hostDirsInArch = lib.attrsets.filterAttrs (name: value: isDirectory value) allEntriesInArch;
          in
            # Map over each host and apply the specific `mkConfig` function
            lib.mapAttrs' (
              hostName: hostValue:
              # This is the key: we call the function passed as an argument
              # to generate the final configuration value.
                if !(isDirectory hostValue)
                then {}
                else mkConfig {inherit archName hostName;}
            )
            hostDirsInArch
      )
      archDirs;
  in
    # Merge the list of attribute sets from all architectures into one big set.
    lib.foldl lib.recursiveUpdate {} listOfConfigs;

  # ── 2. NixOS System Processor ────────────────────────────────────────────────
  # This is now a simple call to the generic `processDir` function.
  processDirNixOS = processDir {
    # NixOS configurations don't run on Darwin.
    validSystems = lib.attrsets.removeAttrs (forAllSystems (system: system)) [
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    # We provide the specific function to build a `nixosSystem`.
    mkConfig = {
      archName,
      hostName,
    }: {
      name = hostName;
      value = nixosSystem {
        system = archName;
        pkgs = import nixpkgs {
          system = archName;
          config = {allowUnfree = true;};
        };
        specialArgs =
          specialArgs
          // {
            system = {
              path = path + "/${archName}";
              name = hostName;
            };
          };
        modules =
          map ifFileExists [
            (path + "/${archName}/configuration.nix")
            (path + "/${archName}/${hostName}/hardware-configuration.nix")
            (path + "/${archName}/${hostName}")
          ]
          ++ optionals (home-manager != {}) [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                backupFileExtension = "hm-bak";
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = specialArgs;
              };
            }
          ];
      };
    };
  };

  # ── 3. Home Manager Processor ────────────────────────────────────────────────
  # This is also a simple call to the generic `processDir` function.
  processDirHomeManager = processDir {
    # We provide the specific function to build a `homeManagerConfiguration`.
    mkConfig = {
      archName,
      hostName,
    }: {
      name = hostName;
      value = homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = archName;
          config = {allowUnfree = true;};
        };
        extraSpecialArgs = specialArgs // {inherit hostName;};
        modules = map ifFileExists [
          (path + "/${archName}/home.nix")
          (path + "/${archName}/${hostName}")
        ];
      };
    };
  };

  # ── 4. Nix Darwin Processor ────────────────────────────────────────────────
  # This is also a simple call to the generic `processDir` function.
  processDirNixDarwin = processDir {
    # Nix Darwin configurations don't run on generic processor.
    validSystems = lib.attrsets.removeAttrs (forAllSystems (system: system)) [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
    ];

    # We provide the specific function to build a `nixDarwinConfiguration`.
    mkConfig = {
      archName,
      hostName,
    }: {
      name = hostName;
      value = darwinSystem {
        system = archName;
        specialArgs =
          specialArgs
          // {
            system = {
              path = path + "/${archName}";
              name = hostName;
            };
          };
        modules =
          map ifFileExists [
            (path + "/${archName}/configuration.nix")
            (path + "/${archName}/${hostName}")
          ]
          ++ optionals (home-manager != {}) [
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                backupFileExtension = "hm-bak";
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = specialArgs;
              };
            }
          ];
      };
    };
  };

  # ── 5. NixOnDroid Processor ────────────────────────────────────────────────
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
        extraSpecialArgs = specialArgs;
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
                extraSpecialArgs = specialArgs;
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
  (getEntries path);

  # ── 6. Template Processor ────────────────────────────────────────────────
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
  (getEntries path);

  # Process directory contents based on the type of system being configured
  # Check if we are processing Home Manager, Nix Darwin, Nix-on-Droid, or NixOS systems
  processed =
    if homeConf
    then processDirHomeManager
    else if darwinConf
    then processDirNixDarwin
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
