{ pkgs, unstable, ... }:
{
  home.packages = with pkgs; [
    (pkgs.discord.override {
      withOpenASAR = true;
      withVencord = true;
      vencord = pkgs.vencord.overrideAttrs {
        src = fetchFromGitHub {
          owner = "Vendicated";
          repo = "Vencord";
          rev = "main";
          hash = "sha256-i/n7qPQ/dloLUYR6sj2fPJnvvL80/OQC3s6sOqhu2dQ=";
        };
      };
    })
    # unstable.${pkgs.system}.vesktop # for screen sharing on wayland
  ];
}
