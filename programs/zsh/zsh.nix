{ pkgs
, user
, ...
}:

{
  # Zsh and Oh-My-Zsh setup
  programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      shellAliases = {
        la = "eza --icons -la  --group-directories-first";
        ls = "eza --icons --grid --group-directories-first";
      };
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      # shellInit = ''
      #   source /home/${user}/flake/programs/zsh/.zshrc
      # '';
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
      #autosuggestions.highlightStyle = "fg=cyan";
      #oh-my-zsh = {
      #  #enableBashCompletion = true;
      #  enable = true;
      #  plugins = [
      #    "git"
      #    "sudo"
      #    "terraform"
      #    "systemadmin"
      #    "vi-mode"
      #  ]; 
      #  theme = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      #};
    };
    oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      useTheme = "amro";
    };
  };

}
