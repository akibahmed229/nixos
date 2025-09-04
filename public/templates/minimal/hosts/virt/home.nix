# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  lib,
  user,
  state-version,
  ...
}: {
  # your imports & home configuration goes here,...
  home = {
    username = lib.mkDefault user;
    homeDirectory = lib.mkDefault "/home/${user}";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = state-version;
}
