{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    eza
    fzf
    bat
    dwt1-shell-color-scripts
  ];

  programs = {
    # --- Zsh setup ---
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;

      # History config
      history = {
        size = 1000000;
        save = 1000000;
        ignoreDups = true;
        ignoreSpace = true;
        path = "${config.xdg.dataHome}/zsh/zsh_history";
      };

      # Extra shell environment / aliases / bindings
      envExtra = ''
        # Startup
        colorscript random
        set -o vi

        # History options
        setopt hist_ignore_all_dups
        setopt hist_ignore_space
        setopt hist_reduce_blanks
        setopt hist_verify

        # Usability
        setopt extended_glob   # Advanced globbing
        setopt autocd          # Auto cd into dirs
        setopt correct         # Command auto-correct

        # Key bindings
        stty -ixon                 # Disable Ctrl-S/Ctrl-Q flow control
        bindkey -s '^Q' 'clear\n'  # Ctrl-Q = clear
        bindkey -s '^O' 'find-file\n'  # Ctrl-O → open file
        bindkey -s '^F' 'find-dir\n' # Ctrl-F → open dir


        # Short aliases
        alias ll='ls -l'
        alias cat='bat'
        alias ga='git add'
        alias gc='git commit'
        alias gs='git status'
        alias gd='git diff'
        alias ..='cd ..'
      '';

      # Declarative aliases
      shellAliases = {
        la = "eza --icons -la --group-directories-first";
        ls = "eza --icons --grid --group-directories-first";
        gp-all = "git push -u github main && git push -u gitlab main";
      };

      # Initialization hooks
      initContent = ''
        # Fzf
        source <(fzf --zsh)

        # Atuin history sync (if enabled)
        ${
          if config.programs.atuin.enable
          then ''eval "$(atuin init zsh)"''
          else ""
        }

        # Direnv (if enabled)
        ${
          if config.programs.direnv.enable
          then ''
            eval "$(direnv hook zsh)"
            export DIRENV_LOG_FORMAT=""
          ''
          else ""
        }

        # Locale + manpager
        export LANG="en_US.UTF-8"
        export MANPAGER="nvim +Man!"

        # fzf-based directory finder
        function find-dir() {
          local dir
          dir=$(find . -type d 2>/dev/null | fzf)
          [[ -n "$dir" ]] && cd "$dir" || cd "$(pwd)"
        }

        # fzf-based file finder with preview in bat
        function find-file() {
          local file
          file=$(fzf --preview 'bat --style=numbers --color=always {}' 2>/dev/null)

          if [[ -n "$file" ]]; then
            nvim "$file"
          fi
        }
      '';

      # Syntax highlighting
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
          "pattern"
          "cursor"
          "regexp"
          "root"
          "line"
        ];
        styles = {
          alias = "fg=magenta,bold";
        };
      };
    };

    # --- Prompt setup (Oh My Posh) ---
    oh-my-posh = {
      enable = true;
      package = pkgs.oh-my-posh;
      enableBashIntegration = true;
      enableZshIntegration = true;
      useTheme = "gruvbox";
    };
  };
}
