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
      envExtra = ''
                        colorscript random
                        setopt hist_ignore_all_dups     # Ignore duplicate commands in history
                        setopt hist_ignore_space        # Ignore commands starting with a space in h>
                        setopt hist_reduce_blanks       # Remove redundant blanks from history
                        setopt hist_verify              # Verify history expansions before execution
                        # setopt
                        setopt extended_glob            #  control over file matching
                        setopt autocd                   # enable auto cd
                        setopt correct                  # Enable auto-correction
                        # alias
                        alias ll='ls -l'
                        alias cat='bat'
                        alias ga='git add'
                        alias gc='git commit'
                        alias gs='git status'
                        alias gd='git diff'
                        alias ..='cd ..'
        		            #alias vim='nvim'
                        # history search
                        bindkey "^[[A" history-beginning-search-backward
                        bindkey "^[[B" history-beginning-search-forward
                        bindkey 'Ctrl-g' kill-line
                        bindkey 'Ctrl-A' beginning-of-line
                        bindkey 'Ctrl-E' end-of-line
      '';
      shellAliases = {
        la = "eza --icons -la  --group-directories-first";
        ls = "eza --icons --grid --group-directories-first";
      };
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      initExtra = ''
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