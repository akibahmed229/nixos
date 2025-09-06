{
  pkgs,
  config,
  ...
}: {
  programs.wofi = {
    enable = true;
    package = pkgs.wofi;
    settings = {
      allow_images = true;
      show = "drun";
      prompt = "Search";
      term = "kitty";
      print_command = true;
      insensitive = true;
      columns = 1;
      no_actions = true;
      hide_scroll = true;
      style = "${config.home.homeDirectory}/.config/wofi/style.css";
    };
  };
}
