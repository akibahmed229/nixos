# `nix build .#nixosConfigurations.minimalISO.config.system.build.isoImage` - from nix-config directory to generate the iso manually
#
# Generated images will be output to the ~/nix-config/results directory unless drive is specified
{
  pkgs,
  lib,
  ...
}: {
  # (Custom nixos modules)
  nm.grub.enable = lib.mkForce false;

  # The default compression-level is (6) and takes too long on some machines (>30m). 3 takes <2m
  isoImage.squashfsCompression = "zstd -Xcompression-level 3";

  # FIXME: Reference generic nix file
  nix = lib.mkDefault {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    extraOptions = "experimental-features = nix-command flakes";
  };

  environment.systemPackages = with pkgs; [
    # for debugging
    htop
    vim
    wget
    curl
    git
    p7zip
    zip
    unzip
    wl-clipboard
    cryptsetup
    gptfdisk
    # for ssh
    openssh
    # for nix
    nix
    # for qemu
    spice-vdagent
    guestfs-tools
  ];

  services = {
    qemuGuest.enable = true; # For guest integration (e.g., shutdown from host)
    spice-vdagentd.enable = true; # For clipboard sharing, dynamic resolution
    spice-webdavd.enable = true; # For folder sharing over SPICE

    openssh = {
      ports = lib.mkForce [22];
      settings.PermitRootLogin = lib.mkForce "yes";
    };
  };

  networking = {
    wireless.enable = false;
  };

  systemd = {
    services.sshd.wantedBy = lib.mkForce ["multi-user.target"];
    # gnome power settings to not turn off screen
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
}
