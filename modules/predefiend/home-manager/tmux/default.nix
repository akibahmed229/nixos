{pkgs, ...}: {
  home.packages = with pkgs; [moreutils tmux-sessionizer];
  programs.tmux = {
    enable = true;
    secureSocket = false;
    newSession = true;
    keyMode = "vi";
    mouse = true;
    terminal = "screen-256color";
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.yank
      tmuxPlugins.tmux-fzf
      {
        plugin = pkgs.tmuxPlugins.tmux-nova;
        extraConfig = ''
          set -g @plugin 'o0th/tmux-nova'

          set -g @nova-nerdfonts true
          set -g @nova-nerdfonts-left 
          set -g @nova-nerdfonts-right 

          set -g @nova-pane-active-border-style "#3c3836"
          set -g @nova-pane-border-style "#282a36"
          set -g @nova-status-style-bg "#3c3837"
          set -g @nova-status-style-fg "#d8dee9"
          set -g @nova-status-style-active-bg "#8ec07c"
          set -g @nova-status-style-active-fg "#4f4b4a"
          set -g @nova-status-style-double-bg "#4f4b4a"

          set -g @nova-pane "#I#{?pane_in_mode,  #{pane_mode},}  #W"

          set -g @nova-segment-mode "#{?client_prefix,Ω,ω}"
          set -g @nova-segment-mode-colors "#458588 #3c3836"

          set -g @nova-segment-whoami "#{pane_current_path}"
          set -g @nova-segment-whoami-colors "#458588 #3c3836"

          set -g @nova-rows 0
          set -g @nova-segments-0-left "mode"
          set -g @nova-segments-0-right "whoami"
        '';
      }

      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-capture-pane-contents 'off'   # avoid restoring junk output

        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on' # manage by systemd service
          set -g @continuum-save-interval '5'
        '';
      }
    ];
    extraConfig = ''
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -q -g status-utf8 on                  # expect UTF-8 (tmux < 2.2)
      setw -q -g utf8 on
      set -g mouse on

      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Vim style pane selection
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Start windows and panes at 1, not 0
      set -g base-index 2
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Use Alt-arrow keys without prefix key to switch panes
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Shift arrow to switch windows
      bind -n S-Left  previous-window
      bind -n S-Right next-window

      # Shift Alt vim keys to switch windows
      bind -n M-H previous-window
      bind -n M-L next-window

      # set vi-mode
      set-window-option -g mode-keys vi

      # keybindings Press C-space. Press [. Navigate to the start of the text you want to copy using h, j, k, l.
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
  };

  systemd.user = {
    services.tmux = {
      Unit = {
        description = "Start the tmux server";
      };
      Install = {
        WantedBy = ["default.target"]; # Where the service should be enabled
      };
      Service = {
        ExecStart = "${pkgs.tmux}/bin/tmux new-session -d -s boot";
        Type = "simple";
        Restart = "on-failure"; # Optional: Restart policy
      };
    };
  };
}
