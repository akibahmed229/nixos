# common configuration for across all systems
{
  config,
  pkgs,
  user,
  hostname,
  lib,
  inputs,
  self,
  ...
}: {
  imports =
    [
      inputs.disko.nixosModules.default
    ]
    ++ [(import ./desktop/disko.nix {device = "/dev/nvme1n1";})];

  # networking options
  networking.hostName = "${hostname}"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  # systemd.services.NetworkManager-wait-online.enable = false; # some ssystemd services may require network to be up before starting.

  # Set your time zone.
  time.timeZone = "Asia/Dhaka";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #   useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      devices = ["nodev"]; # install grub on efi
      efiSupport = true;
      useOSProber = true; # To find Other boot manager like windows
      configurationLimit = 10; # Store number of config
    };
    timeout = 3; # Boot Timeout
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  # User
  users.users = {
    ${user} = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "123456";
      isNormalUser = true;
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "networkmanager" "video" "audio" "input" "disk"];
    };
  };

  programs = {
    # Enable ADB for Android and other stuff.
    adb.enable = true;
    zsh.enable = true;
    dconf.enable = true; # Enable dconf to manage settings.
  };

  # environment variables Setting
  environment = {
    variables = {
      TERMINAL = "alacritty";
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "firefox";
    };
  };

  # Font Setting
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      font-awesome
      lohit-fonts.bengali
      jetbrains-mono
      source-han-sans
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["Meslo LG M Regular Nerd Font Complete Mono"];
        serif = ["Noto Serif" "Source Han Serif"];
        sansSerif = ["Noto Sans" "Source Han Sans"];
      };
    };
  };

  # Delete Garbage Collection previous generation collection & enable flake
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # given the users in this list the right to specify additional substituters via:
      #    1. `nixConfig.substituters` in `flake.nix`
      trusted-users = ["${user}"];

      # the system-level substituters & trusted-public-keys
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];

      auto-optimise-store = true;
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };

    extraOptions = ''
      accept-flake-config = true # Enable substitution from flake.nix

      keep-outputs = true # Keep build outputs for debugging purposes
      keep-derivations = true

      #  free up to 5GiB whenever there is less than 10GiB left:
      min-free = ${toString (10240 * 1024 * 1024)}
      max-free = ${toString (5120 * 1024 * 1024)}
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };

    # Opinionated: enable channels
    channel.enable = true;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };
  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  # XDG  paths
  environment.sessionVariables = rec {
    WALLPAPER = "/home/${user}/.config/flake/public/wallpapers";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # Not officially in the specification
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [
      "${XDG_BIN_HOME}"
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [8080];
    settings = lib.mkDefault {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  security.allowSimultaneousMultithreading = true; # simultaneous multithreading of CPU cores

  programs = {
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  boot = {
    # Disable init=/bin/sh as a kernel parameter to prevent root access

    # /tmp should be treated as volatile storage!
    tmp.useTmpfs = lib.mkForce false;
    tmp.cleanOnBoot = lib.mkForce (!config.boot.tmp.useTmpfs);
  };

  system = {
    # Auto upgrade system for flake inputs and nixpkgs weekly
    autoUpgrade = {
      enable = true;
      dates = "weekly";
      flake = self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L"
      ];
      randomizedDelaySec = "45min";
    };
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "24.05"; # Did you read the comment?
  };
}
