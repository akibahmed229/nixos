{pkgs, ...}: {
  home.packages = with pkgs.xfce;
    [
      # For file manager
      thunar
      tumbler
      exo
      thunar-archive-plugin
      thunar-volman
    ]
    ++ (with pkgs; [
      kdePackages.ark
    ]);

  home.file = {
    ".config/Thunar" = {
      source = ./config;
      recursive = true;
    };
  };
}
