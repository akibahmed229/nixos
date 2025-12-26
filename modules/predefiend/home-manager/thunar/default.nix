{pkgs, ...}: {
  home.packages = with pkgs.xfce;
    [
      # For file manager
      thunar
      tumbler
      thunar-archive-plugin
      thunar-volman
    ]
    ++ (with pkgs; [
      kdePackages.ark
      xfce4-exo
    ]);

  home.file = {
    ".config/Thunar" = {
      source = ./config;
      recursive = true;
    };
  };
}
