                # setopt
                neofetch                        # Run neofetch on Zsh shell initialization
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
                alias la='exa -la'
                alias cat='bat'
                alias ga='git add'
                alias gc='git commit'
                alias gs='git status'
                alias ..='cd ..'
		alias vim='nvim'
                # history search
                bindkey "^[[A" history-beginning-search-backward
                bindkey "^[[B" history-beginning-search-forward
                bindkey 'Ctrl-g' kill-line
                bindkey 'Ctrl-A' beginning-of-line
                bindkey 'Ctrl-E' end-of-line
                # export
                export EDITOR='nvim'             # Set the default text editor
                export LANG='en_US.UTF-8'        # Set the default language
                # export LS_COLORS='rs=0:di=38;5;27:ln=38;5;51:ex=38;5;21:*.txt=38;5;226'  #>
                # export CLICOLOR='1'                                                     # >
                # ps1
                export PS1="%B%n@%m %~ %#%b "
