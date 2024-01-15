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
      # '';
      initExtra = ''
        source /home/${user}/flake/modules/predefiend/home-manager/zsh/.zshrc
        export LANG="en_US.UTF-8";
        function tmux-sesssion {
        BUFFER='tmux-sessionizer'
            zle accept-line
        }
        zle -N tmux-sesssion
        bindkey '^f' tmux-sesssion
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
      useTheme = "catppuccin_mocha";
    };
  };

}
