{ pkgs, unstable, inputs, ... }:
let
  spicetify-nix = inputs.spicetify-nix;
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in
{
  # import the flake's module for your system
  imports = [ spicetify-nix.homeManagerModule ];

  # configure spicetify :)
  programs.spicetify =
    {
      enable = true;
      theme = spicePkgs.themes.Onepunch;
      colorScheme = "gruvbox";

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle # shuffle+ (special characters are sanitized out of ext names)
        hidePodcasts
        autoSkipExplicit
      ];
    };
}
