# This is your default configuration file.
{
  pkgs,
  user,
  ...
}: {
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
