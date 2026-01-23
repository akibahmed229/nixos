{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.hm.spotify;

  # Access the spicetify packages based on system
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  options.hm.spotify = {
    enable = mkEnableOption "Custom Spicetify Spotify configuration";

    theme = mkOption {
      type = types.attrs;
      default = spicePkgs.themes.onepunch;
      description = "The Spicetify theme package to use.";
    };

    colorScheme = mkOption {
      type = types.str;
      default = "dark";
      description = "The color scheme for the chosen theme.";
    };

    extraExtensions = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional Spicetify extensions.";
    };
  };

  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;

      # Use the user-defined theme or the default Onepunch
      theme = cfg.theme;
      colorScheme = cfg.colorScheme;

      enabledExtensions = with spicePkgs.extensions;
        [
          adblock
          hidePodcasts
          shuffle
        ]
        ++ cfg.extraExtensions;

      enabledCustomApps = with spicePkgs.apps; [
        newReleases
        ncsVisualizer
      ];

      enabledSnippets = with spicePkgs.snippets; [
        rotatingCoverart
        pointer
      ];
    };
  };
}
