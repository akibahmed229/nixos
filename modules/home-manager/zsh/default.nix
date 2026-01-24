{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.zsh;
in {
  options.hm.zsh = {
    enable = mkEnableOption "Zsh shell configuration";

    colorscripts = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to run a random shell color script on startup.";
    };

    viMode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Vi keybindings.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      eza
      fzf
      bat
      dwt1-shell-color-scripts
    ];

    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
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

      # Shell Aliases
      shellAliases = {
        la = "eza --icons -la --group-directories-first";
        ls = "eza --icons --grid --group-directories-first";
        ll = "ls -l";
        cat = "bat";
        ga = "git add";
        gc = "git commit";
        gs = "git status";
        gd = "git diff";
        ".." = "cd ..";
        gp-all = "git push -u github main && git push -u gitlab main";
      };

      # Logic and Functions
      initContent = ''
        # --- UI & Behavior ---
        ${optionalString cfg.colorscripts "colorscript random"}
        ${optionalString cfg.viMode "set -o vi"}

        # History options
        setopt hist_ignore_all_dups
        setopt hist_ignore_space
        setopt hist_reduce_blanks
        setopt hist_verify

        # Usability
        setopt extended_glob
        setopt autocd
        setopt correct

        # --- Functions ---
        extract() {
          if [ -f $1 ]; then
            case $1 in
              *.tar.bz2) tar xjf $1 ;;
              *.tar.gz)  tar xzf $1 ;;
              *.bz2)     bunzip2 $1 ;;
              *.rar)     unrar x $1 ;;
              *.gz)      gunzip $1  ;;
              *.tar)     tar xf $1  ;;
              *.tbz2)    tar xjf $1 ;;
              *.tgz)     tar xzf $1 ;;
              *.zip)     unzip $1   ;;
              *.Z)       uncompress $1 ;;
              *.7z)      7z x $1    ;;
              *)         echo "'$1' cannot be extracted" ;;
            esac
          else
            echo "'$1' is not a valid file"
          fi
        }

        mkcd() { mkdir -p "$1" && cd "$1"; }
        backup() { cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"; }
        replace() { grep -rl "$1" . | xargs sed -i "s/$1/$2/g"; }
        path() { echo "$PATH" | tr ':' '\n'; }

        # fzf integration
        find-dir() {
          local dir
          dir=$(find . -type d 2>/dev/null | fzf)
          [[ -n "$dir" ]] && cd "$dir"
        }

        find-file() {
          local file
          file=$(fzf --preview 'bat --style=numbers --color=always {}' 2>/dev/null)
          [[ -n "$file" ]] && nvim "$file"
        }

        # --- Key Bindings ---
        stty -ixon
        bindkey -s '^Q' 'clear\n'
        bindkey -s '^O' 'find-file\n'
        bindkey -s '^F' 'find-dir\n'

        # --- External Hooks ---
        source <(fzf --zsh)
        ${optionalString config.programs.atuin.enable ''eval "$(atuin init zsh)"''}
        ${optionalString config.programs.direnv.enable ''
          eval "$(direnv hook zsh)"
          export DIRENV_LOG_FORMAT=""
        ''}

        # Misc Environment
        export LANG="en_US.UTF-8"
        export MANPAGER="nvim +Man!"
      '';

      syntaxHighlighting = {
        enable = true;
        highlighters = ["main" "brackets" "pattern" "cursor" "regexp" "root" "line"];
        styles = {alias = "fg=magenta,bold";};
      };
    };
  };
}
