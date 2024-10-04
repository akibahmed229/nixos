# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  pkgs,
  user,
  ...
}: {
  # your imports & home configuration goes here,...
  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

}
