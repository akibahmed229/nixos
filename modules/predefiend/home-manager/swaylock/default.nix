{
  pkgs,
  unstable,
  ...
}: {
  # home.packages = with unstable.${pkgs.system}; [
  #   swaylock-effects
  #   swaylock
  #];

  home.file = {
    ".config/swaylock" = {
      source = ./config;
      recursive = true;
    };
  };
}
