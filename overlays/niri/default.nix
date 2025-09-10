# niri-overlay.nix
{inputs, ...}: final: prev: {
  niri = prev.niri.overrideAttrs (old: rec {
    version = "main";

    src = prev.fetchFromGitHub {
      owner = "YaLTeR";
      repo = "niri";
      rev = "v${version}";
      hash = "sha256-RLD89dfjN0RVO86C/Mot0T7aduCygPGaYbog566F0Qo=";
    };

    cargoHash = "sha256-lR0emU2sOnlncN00z6DwDIE2ljI+D2xoKqG3rS45xG0=";

    meta =
      old.meta
      // {
        description = "Scrollable-tiling Wayland compositor (custom overlay build)";
      };
  });
}
