# Default home-manager configuration across all machines
{
  pkgs,
  user,
  ...
}: {
  # Configure your nixpkgs instance
  config = {
    # Disable if you don't want unfree packages
    allowUnfree = true;
  };

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
