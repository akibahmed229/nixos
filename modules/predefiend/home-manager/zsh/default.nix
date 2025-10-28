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

        # Custom Keybinds
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

        # Extract any archive:
        extract() {
            if [ -f $1 ]; then
                case $1 in
                    *.tar.bz2)   tar xjf $1     ;;
                    *.tar.gz)    tar xzf $1     ;;
                    *.bz2)       bunzip2 $1     ;;
                    *.rar)       unrar x $1     ;;
                    *.gz)        gunzip $1      ;;
                    *.tar)       tar xf $1      ;;
                    *.tbz2)      tar xjf $1     ;;
                    *.tgz)       tar xzf $1     ;;
                    *.zip)       unzip $1       ;;
                    *.Z)         uncompress $1  ;;
                    *.7z)        7z x $1        ;;
                    *)           echo "'$1' cannot be extracted" ;;
                esac
            else
                echo "'$1' is not a valid file"
            fi
        }

        # Create and enter directory:
        mkcd() {
            mkdir -p "$1" && cd "$1"
        }

        # Quick backup:
        backup() {
            cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
        }

        # Find and replace in files:
        replace() {
            grep -rl "$1" . | xargs sed -i "s/$1/$2/g"
        }

        # Show PATH one per line:
        path() {
            echo "$PATH" | tr ':' '\n'
        }

        # fzf-based directory finder
        find-dir() {
          local dir
          dir=$(find . -type d 2>/dev/null | fzf)
          [[ -n "$dir" ]] && cd "$dir" || cd "$(pwd)"
        }

        # fzf-based file finder with preview in bat
        find-file() {
          local file
          file=$(fzf --preview 'bat --style=numbers --color=always {}' 2>/dev/null)

          if [[ -n "$file" ]]; then
            nvim "$file"
          fi
        }
      '';

      # Declarative aliases
      shellAliases = {
        la = "eza --icons -la --group-directories-first";
        ls = "eza --icons --grid --group-directories-first";
        gp-all = "git push -u github main && git push -u gitlab main";
      };

      # Initialization hooks
      initContent = ''
        # Only run in interactive shells (prevents scp/sftp issues)
        [[ $- != *i* ]] && return

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

        # Key bindings
        stty -ixon                 # Disable Ctrl-S/Ctrl-Q flow control
        bindkey -s '^Q' 'clear\n'  # Ctrl-Q = clear
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
  };
}
