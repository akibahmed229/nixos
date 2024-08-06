<p align="center"><img src="https://i.imgur.com/NbxQ8MY.png" width=600px></p>

<h2 align="center">Akib | NixOS Config Go Wilde</h2>

<h2 align="center"> Current System Preview </h2>

![my current setup](./public/preview/Current.png)

# 1. Installation My version of NixOS

<details>

<summary>NixOS setup using falke and home-manager as module. Hyperland as default Window Manager.</summary>

## Installation Prerequisites

Before you begin, ensure you have the following:

- A Linux system with an EFI-enabled BIOS (for BIOS installations, adjust the commands accordingly).
- The disk identifier (`/dev/sdX`) for the target installation disk. Replace `sdX` with the appropriate disk identifier for your system.

## Installation Steps

**Install NixOS**

```bash
sudo su
nix-shell -p git --command 'nix run github:akibahmed229/nixos#akibOS --experimental-features "nix-command flakes"'
```

> **NOTE**:
> During the installation process, [akibOS](./pkgs/akibOS/default.nix) will prompt for the disk identifier (`/dev/sdX`) , hostname and the username. Replace `sdX` with the appropriate disk identifier for your system.
> also replace `hostname` with (available options: desktop, virt) and `username` with your desired username.
> the default password for the user is `123456` you can change it later.

Congratulations! You have successfully installed NixOS with a Btrfs filesystem. Enjoy your fault-tolerant, advanced feature-rich, and easy-to-administer system!

> **NOTE**:
> The Configuration will clone from this repository and will be placed in `/home/username/.config/flake` respectively.
> For more information about NixOS and its configuration options, refer to the official [NixOS documentation](https://nixos.org/).

**After installation:**

- Open a terminal with "Super + Return".
- Navigate to the `~/.config/flake` directory in the terminal.
- Fix permission issues by running these commands:

```bash
chown -R yourUserName:users *
chown -R yourUserName:users .*
```

</details>

# 2. File Structure

<details>
  <summary>File Structure</summary>

- **Flake.nix** : Main flake file for defining the system configuration

  - **home-manager** : Configuration files for Home Manager and desktop environment
  - **hosts** : Host-specific configuration files
  - **modules** : Program-specific configuration files (includes custom and predefined modules for NixOS and Home Manager)
  - **pkgs** : Nix derivations, custom packages, and shell scripts
  - **public** : Wallpaper folder, GTK, and QT themes and doc
  - **flake.lock** : Lock file for the flake inputs

- **_devShell/flake.nix_** : Flake file defining the development shell

</details>

# 3. This Flake Provide

- <details>
  <summary>Overlays for custom packages and Nixpkgs</summary>
  </br>

  You can also plug this into a flake to include it into a system configuration.

  ```nix
  {
      inputs = {
       akibOS.url = "github:akibahmed229/nixos";
      };
  }
  ```

  This input can then be used as an overlay to replace the default Nixpkgs with the custom one. (nixos , home-manager)

  ```nix
  {inputs, ... }:
  {
      nixpkgs.overlays = [
         inputs.akibOS.overlays.discord-overlay # pull the latest version of discord
         inputs.akibOS.overlays.nvim-overlay # my custom nvim with nixvim
         inputs.akibOS.overlays.flatpak-overlay # patch flatpak font
         inputs.akibOS.overlays.unstable-packages # pull pkgs from unstable. be accissible through `pkgs.unstable`
      ];
  }
  ```

  </details>

- <details>
   <summary>DevShell for development environments</summary>
   </br>
   
   you can access the development shell by running the following command:
   
   ```bash
   nix develop github:akibahmed229/nixos#kernel_build_env # kernel development environment
   nix develop github:akibahmed229/nixos#jupyter # jupyter development environment
   nix develop github:akibahmed229/nixos#gtk3_env # gtk3 development environment
   nix develop github:akibahmed229/nixos#prisma # prisma query engine
   ```

  </details>

- <details>
   <summary>Custom Pkgs & Shell scripts</summary>
   </br>
   
   you can access the shell scripts by running the following command:
   
   ```bash
   nix run github:akibahmed229/nixos#nix-update-input # this will update specific flake input of you flake.nix
   nix run github:akibahmed229/nixos#nixvim # you can try my custom nixvim
   nix run github:akibahmed229/nixos#wallpaper # you need to define your env variable $WALLPAPER
   ```

  You can also plug this into a flake to include it into a system configuration.

  ```nix
  {
      inputs = {
       akibOS.url = "github:akibahmed229/nixos";
      };
  }
  ```

  This input can then be used as Nixpkgs with the custom one. (nixos , home-manager)

  From NixOS Configuration

  ```nix
  {inputs, pkgs,... }:
  {
      environment.systemPackages = with pkgs; [
        inputs.akibOS.packages.${pkgs.system}.wallpaper # make sure you have set the env variable $WALLPAPER
        inputs.akibOS.packages.${pkgs.system}.custom_nsxiv # my modify version of nsxiv
      ];

      # custom pkgs for sddm theme for
      services.displayManager.sddm = {
        enable = true;
        theme = ''${inputs.akibOS.packages.${pkgs.system}.custom_sddm.override {
            imgLink = {
              url = "https://raw.githubusercontent.com/akibahmed229/nixos/main/public/wallpaper/nix-wallpaper-nineish-dark-gray.png"; # you can change the image for sddm theme
              sha256 = "07zl1dlxqh9dav9pibnhr2x1llywwnyphmzcdqaby7dz5js184ly"; # change the hash accordingly
            };
          }}'';
      };
  }
  ```

  From Home Manager

  ```nix
  {inputs, pkgs,... }:
  {
     home.packages  = with pkgs; [
        inputs.akibOS.packages.${pkgs.system}.wallpaper # make sure you have set the env variable $WALLPAPER
        inputs.akibOS.packages.${pkgs.system}.custom_nsxiv # my modify version of nsxiv
      ];
  }
  ```

  </details>

- <details>
  <summary>My Custom lib helper (flake lib) allow multiple hosts with easy-to-administer</summary>
  </br>

  You can plug this into a flake to make your nixosSystem configuration **_(flake and home-manager as modules)_**

  ```nix
  {
    inputs = {
       nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
       home-manager = {
        url = "github:nix-community/home-manager/release-24.05";
        inputs.nixpkgs.follows = "nixpkgs";
       };
       akibOS.url = "github:akibahmed229/nixos";
    };
    outputs = {
        self, # The special input named self refers to the outputs and source tree of this flake
        nixpkgs,
        home-manager,
        akibOS,
        ...
    # inputs@ is a shorthand for passing the inputs attribute into the outputs parameters
    } @ inputs: let
      system = "x86_64-linux";
      # FIXME: Replace with your username
      user = "akib"

      pkgs = import nixpkgs {
        inherit system;
        config = {allowUnfree = true;};
      };

      mkSystem = akibOS.lib.mkSystem {
        # need to be passed
        inherit (nixpkgs) lib;
        inherit pkgs system home-manager;

        # Set all inputs parameters as special arguments for all submodules,
        # so you can directly use all dependencies in inputs in submodules
        specialArgs = {inherit inputs user;}; # pass args as your requirement (make sure to pass user)
      };
    in {
        nixosConfigurations = mkSystem ./hosts;
    };
  }
  ```

  **In the above example `./hosts` is the hosts specific file see [hosts](./hosts) where you need to define one common config file for nixos system `./hosts/configuration.nix` and `yourHostName` directory which will contain `./hosts/desktop/default.nix` and `./hosts/desktop/hardware-configuration.nix` which will import by default your `default.nix` file.**

  > **_Note:_** You can have multiple hosts by adding directory for each host as mention above.

  example `./hosts/configuration.nix` configuration

  ```nix
    # This is your default configuration file.

    {pkgs, user,...}:{
      # your default configuration for all system goes here,...

      # Configure your nixpkgs instance
      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
      };

      users.users = {
        ${user} = {
          # TODO: You can set an initial password for your user.
          # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
          # Be sure to change it (using passwd) after rebooting!
          initialPassword = "correcthorsebatterystaple";
          isNormalUser = true;
          # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
          extraGroups = ["wheel"];
        };
      };

      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      system.stateVersion = "24.05";
    }
  ```

  example `./hosts/desktop/default.nix` configuration

  ```nix
    # This is your system's configuration file.
    # Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

    {pkgs, user,...}:{
      # your imports goes here,...
      # make sure to import the hardware-configuration
      imports = [(import ./hardware-configuration.nix)];

      # your configuration goes here,...
      environment.systemPackages = with pkgs; [nvim];

      # home-manager configuration
      home-manager = {
        users.${user} = {
          imports = [
            # TODO: import your home.nix file and other home-manager stuff
            # make sure to import home configuration
            (import ./home.nix)
          ];
        };
      };
    }
  ```

  example `./hosts/desktop/hardware-configuration.nix` configuration

  ```nix
    # This is just an example, you should generate yours with nixos-generate-config and put it in here.

    {
      boot.loader.systemd-boot.enable = true;

      fileSystems."/" = {
        device = "/dev/sda1";
        fsType = "ext4";
      };

      # Set your system kind (needed for flakes)
      nixpkgs.hostPlatform = "x86_64-linux";
    }
  ```

  example `./hosts/desktop/home.nix` configuration

  ```nix
    # This is your home-manager configuration file
    # Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

    {pkgs, user,...}:{

      # your imports & home configuration goes here,...
      imports = [ ];

      # Configure your nixpkgs instance
      config = {
         # Disable if you don't want unfree packages
         allowUnfree = true;
         # Workaround for https://github.com/nix-community/home-manager/issues/2942
         allowUnfreePredicate = _: true;
      };

      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
      };

      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      home.stateVersion = "24.05";
    };
  ```

  **Accessible through :** `$ nixos-rebuild switch --flake .#<host-name>`

  > **_Note_** : `host-name` will be your directory name that you create in `./hosts`
  > In our case host name will be `desktop` as we created directory in `./hosts/desktop/`

  > **`$ nixos-rebuild switch --flake .#desktop`**

  </details>
