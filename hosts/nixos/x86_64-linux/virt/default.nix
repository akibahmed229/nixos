/*
* Host-specific configuration for NixOS systems.
* This is your system's configuration file.
* Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
*/
{
  self,
  pkgs,
  user,
  theme,
  state-version,
  system,
  inputs,
  lib,
  ...
}: let
  # My custom lib helper functions
  inherit (self.lib) mkRelativeToRoot;
in {
  imports = [(mkRelativeToRoot "home-manager/dwm")];

  users.defaultUserShell = pkgs.zsh;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      spice-vdagent
      guestfs-tools
      cryptsetup
      wget
      direnv
      fastfetch
    ];
    shells = [pkgs.zsh];
    pathsToLink = ["/share/zsh" "/tmp" "/home/${user}"];
  };

  # Custom nixos modules for
  nm = {
    # User management configuration ( custom module ) - see modules/custom/nixos/user
    setUser = {
      name = user;
      usersPath = ./users/.;
      nixosUsers.enable = true;
      homeUsers.enable = true;

      system = {
        desktopEnvironment = "dwm";
        inherit state-version;
        inherit (system) path name;
      };
    };

    # Enable Intel gpu
    gpu = {
      enable = true;
      vendor = "intel";
    };

    # kubernetes  ( custom module )
    k8s = {
      enable = true;
      role = "worker";
      kubeMasterIP = "192.168.0.111";
    };

    # (IPC) communication between different applications and system components.
    dbus.enable = true;

    # System theme
    stylix = {
      enable = true;
      themeScheme = mkRelativeToRoot "public/themes/base16Scheme/${theme}.yaml";
    };

    # Persistant storage
    impermanence = {
      enable = true;
      inherit user; # REQUIRED: Set your primary username
      systemDirs = [
        # state for containers and orchestrators
        "/var/lib/docker"
        "/var/lib/kubernetes"
        "/var/lib/cfssl"
        "/var/lib/kubelet"
        "/var/lib/containerd"
        "/var/lib/etcd"
      ];
    };

    # Secret management
    sops = {
      enable = true;
      defaultSopsFile = "${builtins.toString inputs.secrets}/secrets/secrets.yaml";
      secrets = {
        "akib/password/root_secret".neededForUsers = true;
        "akib/password/my_secret".neededForUsers = true;
      };
    };
  };

  services.openssh.ports = lib.mkForce [22];

  services = {
    qemuGuest.enable = true; # For guest integration (e.g., shutdown from host)
    spice-vdagentd.enable = true; # For clipboard sharing, dynamic resolution
    spice-webdavd.enable = true; # For folder sharing over SPICE
  };
}
