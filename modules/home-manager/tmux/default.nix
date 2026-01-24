{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.tmux;
in {
  options.hm.tmux = {
    enable = mkEnableOption "Tmux terminal multiplexer configuration";
    systemdEnable = mkOption {
      type = types.bool;
      default = false;
      description = "The tmux services.";
    };
    prefix = mkOption {
      type = types.str;
      default = "C-Space";
      description = "The tmux prefix key.";
    };
    terminal = mkOption {
      type = types.str;
      default = "screen-256color";
      description = "The default terminal type.";
    };
  };

  config = mkIf cfg.enable {
    # Dependencies for your session management scripts
    home.packages = with pkgs; [
      moreutils
      tmux-sessionizer
    ];

    programs.tmux = {
      enable = true;
      secureSocket = false;
      newSession = true;
      keyMode = "vi";
      mouse = true;
      terminal = cfg.terminal;

      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
        yank
        tmux-fzf
        {
          plugin = tmux-nova;
          extraConfig = ''
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
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-strategy-vim 'session'
            set -g @resurrect-capture-pane-contents 'off'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-boot 'on'
            set -g @continuum-save-interval '5'
          '';
        }
      ];

      extraConfig = ''
        set-option -sa terminal-overrides ",xterm*:Tc"
        set -g mouse on

        # Prefix Configuration
        unbind C-b
        set -g prefix ${cfg.prefix}
        bind ${cfg.prefix} send-prefix

        # Window/Pane Splitting
        bind '"' split-window -v -c "#{pane_current_path}"
        bind %   split-window -h -c "#{pane_current_path}"

        # Config Reload
        unbind r
        bind r source-file $HOME/.config/tmux/tmux.conf

        # Indexing and Renumbering
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # Navigation (Vim Style)
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Quick Window/Pane Switching (Alt/Shift)
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D
        bind -n S-Left  previous-window
        bind -n S-Right next-window
        bind -n M-H previous-window
        bind -n M-L next-window

        # Alt+number to select window
        ${concatStringsSep "\n" (map (i: "bind -n M-${toString i} select-window -t ${toString i}") (range 1 9))}

        # Copy Mode (Vim Style)
        set-window-option -g mode-keys vi
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        unbind -T copy-mode-vi MouseDragEnd1Pane
      '';
    };

    # Systemd Boot Service
    systemd.user.services.tmux = {
      Unit = {
        Description = "Start the tmux server";
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        ExecStart = "${pkgs.tmux}/bin/tmux new-session -d -s boot";
        Type = "simple";
        Restart = "on-failure";
      };
    };
  };
}
