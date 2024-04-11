{ pkgs, unstable, ... }:
{
  home.packages = with pkgs; [
    (pkgs.discord.override {
      withOpenASAR = true;
      withVencord = true;
      # vencord = pkgs.vencord.overrideAttrs {
      #   src = fetchFromGitHub {
      #     owner = "Vendicated";
      #     repo = "Vencord";
      #     rev = "main";
      #     hash = "sha256-jkbXLTjKPPxOxVQiPvchP9/EhVxzeomDDRUaP0QDvfE=";
      #   };
      # };
    })
    # unstable.${pkgs.system}.vesktop # for screen sharing on wayland
  ];
}
