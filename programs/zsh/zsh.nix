{ pkgs, ... }:
{
  # Zsh and Oh-My-Zsh setup
  programs = {
    zsh = {
      enable = true;
      shellAliases = {
        la = "eza --icons -la  --group-directories-first";
        ls = "eza --icons --grid --group-directories-first";
      };
      autosuggestions.enable = true;
      enableBashCompletion = true;
      syntaxHighlighting.enable = true;
      shellInit = ''
        source /home/${user}/flake/programs/zsh/.zshrc
      '';
      syntaxHighlighting.highlighters = [
        "main"
        "brackets"
        "pattern"
        "cursor"
        "regexp"
        "root"
        "line"
      ];
      syntaxHighlighting.styles = { "alias" = "fg=magenta,bold"; };
      autosuggestions.highlightStyle = "fg=cyan";
      ohMyZsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "terraform"
          "systemadmin"
          "vi-mode"
        ];
        theme = "agnoster";
      };
    };
  };

}
