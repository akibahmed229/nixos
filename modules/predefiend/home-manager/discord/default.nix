{pkgs, ...}: {
  home.packages = with pkgs; [
    # (pkgs.discord.override {
    #   withOpenASAR = true;
    #   withVencord = true;
    #   # vencord = pkgs.vencord.overrideAttrs {
    #   #   src = fetchFromGitHub {
    #   #     owner = "Vendicated";
    #   #     repo = "Vencord";
    #   #     rev = "v1.7.8";
    #   #     hash = "sha256-5kMBUdFupVxmlQ7NVJ7qzFoyQieDGHrFNkrzhlhEzJ0=";
    #   #   };
    #   # };
    # })
    vesktop # for screen sharing on wayland
  ];

  programs.vesktop = {
    enable = true;
    package = pkgs.vesktop;
  };
}
