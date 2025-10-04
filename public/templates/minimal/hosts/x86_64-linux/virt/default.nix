# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  pkgs,
  user,
  ...
}: {
  imports = [
    (import ../../../utils/impermance.nix)
  ];

  # your configuration goes here,...
  environment.systemPackages = with pkgs; [
    neovim
    htop
    wget
    curl
    git
    p7zip
    zip
    unzip
    wl-clipboard
    cryptsetup
  ];

  # home-manager configuration
  home-manager = {
    users.${user} = {
      imports = [(import ./home.nix)];
    };
  };
}
