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
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",*:RGB"
      set -q -g utf8 on
      set -g mouse on
      set -g set-clipboard on

      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      bind '"' split-window -v -c "#{pane_current_path}"
      bind %   split-window -h -c "#{pane_current_path}"

      unbind r
      bind r source-file $HOME/.config/tmux/tmux.conf

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Vim style pane selection
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

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

      # Vim-like copy/paste
      # keybindings Press C-space. Press [. Navigate to the start of the text you want to copy using h, j, k, l.
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      unbind -T copy-mode-vi MouseDragEnd1Pane

      # Alt+number to select window
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9
    '';
  };

  systemd.user = {
    services.tmux = {
      Unit = {
        Description = "Start the tmux server";
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
