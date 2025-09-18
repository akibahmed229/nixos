{pkgs, ...}: {
  home.packages = with pkgs; [
    alacritty # GPU-accelerated terminal emulator.
  ];

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings =
      builtins.fromTOML
      (builtins.readFile ./config/alacritty.toml);
  };
}
