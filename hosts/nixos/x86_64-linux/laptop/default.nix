{
  inputs,
  user,
  system,
  state-version,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  nm = {
    setUser = {
      name = user;
      usersPath = ./users/.;
      nixosUsers.en = false;
      homeUsers.en = true;

      system = {
        inherit (system) name path;
        inherit state-version;
      };
    };
  };

  # Basic WSL Configuration
  wsl = {
    enable = true;
    usbip.enable = true;
    defaultUser = user;

    usbip.autoAttach = [
      "1-15"
    ];

    wslConf = {
      boot = {
        systemd = true;
      };

      automount = {
        enabled = true;
        root = "/mnt";
        options = "metadata,uid=1003,gid=1003,umask=077,fmask=11,case=off";
        mountFsTab = true;
      };

      interop = {
        enabled = true;
        appendWindowsPath = true;
      };
    };

    startMenuLaunchers = true;
  };

  # System packages must be declared at the top level
  environment.systemPackages = with pkgs; [
    gcc
    cmake
    gnumake
    libtool
    meson
    gettext
    python314
    python314Packages.uv
    nodejs_26
    rustc
    cargo
    jq
    sqlite
    android-tools
    jdk25
    postman
    git
    lazygit
    gh
    dotnetCorePackages.sdk_10_0
  ];
}
