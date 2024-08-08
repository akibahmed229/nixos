# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  pkgs,
  user,
  ...
}: {
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
