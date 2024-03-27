{ pkgs, unstable, inputs, ... }:
let
  inherit (inputs) spicetify-nix;
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in
{
  # import the flake's module for your system
  imports = [ spicetify-nix.homeManagerModule ];

  # configure spicetify :)
  programs.spicetify = {
    # use spotify from the nixpkgs master branch
    # spotifyPackage = unstable.${pkgs.system}.spotify;
    enable = true;
    theme = spicePkgs.themes.Dribbblish;
    colorScheme = "rosepine";

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shuffle # shuffle+ (special characters are sanitized out of ext names)
      hidePodcasts
      autoSkipExplicit
    ];
  };
}
