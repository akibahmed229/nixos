{
  inputs,
  pkgs,
  ...
}: {
  # add the home manager module
  imports = [inputs.ags.homeManagerModules.default];

  programs.ags = {
    enable = true;

    # symlink to ~/.config/ags
    configDir = ./config;

    # additional packages to add to gjs's runtime
    extraPackages = with inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}; [
      hyprland
      apps
      mpris
      notifd
      network
      tray
      wireplumber
      battery
    ];
  };

  # The home-manager module does not expose the astal cli to the home environment
  home.packages = with inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}; [io notifd];
}
