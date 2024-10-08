{pkgs, ...}: let
  resurrectDirPath = "~/.tmux/resurrect";
in {
  # Tmux Config
  programs.tmux = {
    enable = true;
    secureSocket = false;
    shell = "${pkgs.zsh}/bin/zsh"; # or zsh
    newSession = true;
    keyMode = "vi";
    mouse = true;
    terminal = "screen-256color";
    plugins = with pkgs; [
      # tmuxPlugins.catppuccin
      tmuxPlugins.tmux-nova
      tmuxPlugins.sensible
      # tmuxPlugins.gruvbox
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.yank
      tmuxPlugins.tmux-fzf
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''

          # I have tested this strategy to work with neovim but it is not enough to have
          # Session.vim at the root of the path from which the plugin is going to do the restore
          # it is important that for neovim to be saved to be restored from the path where Session.vim
          # exist for this flow to kick in. Which means that even if tmux-resurrect saved the path with
          # Session.vim in it but vim was not open at the time of the save of the sessions then when
          # tmux-resurrect restore the window with the path with Session.vim nothing will happen.

          # Furthermore I currently using vim-startify which among other things is able to restore
          # from Session.vim if neovim is opened from the path where Session.vim exist. So in a
          # sense I don't really need tmux resurrect to restore the session as this already
          # taken care of and this functionality becomes redundant. But as I am not sure if I keep
          # using vim-startify or its auto restore feature and it do not conflict in any way that
          set -g @resurrect-strategy-* 'session'
          # set -g @resurrect-strategy-nvim 'session'
          # set -g @resurrect-strategy-vim 'session'
          # set -g @resurrect-strategy-tmux 'session'

          # This three lines are specific to NixOS and they are intended
          # to edit the tmux_resurrect_* files that are created when tmux
          # session is saved using the tmux-resurrect plugin. Without going
          # into too much details the strings that are saved for some applications
          # such as nvim, vim, man... when using NixOS, appimage, asdf-vm into the
          # tmux_resurrect_* files can't be parsed and restored. This addition
          # makes sure to fix the tmux_resurrect_* files so they can be parsed by
          # the tmux-resurrect plugin and successfully restored.
          #  set -g @resurrect-dir ${resurrectDirPath}
          #  set -g @resurrect-hook-post-save-all 'target=$(readlink -f ${resurrectDirPath}/last); sed "s| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g" $target | sponge $target'
        '';
      }
      # a few words about @continuum-boot and @continuum-systemd-start-cmd that
      # are not used as part of the extraConfig for the continuum plugin.
      #
      # @continuum-boot - when set will generate a user level systemd unit file
      # which it will save to ${HOME}/.config/systemd/user/tmux.service and enable
      # it.
      #
      # @continuum-systemd-start-cmd - The command used to start the tmux server
      # is determined via this configuration, and this command is set in the
      # context of the systemd unit file that is generated by setting @continuum-boot
      # when this option is not set the default will be "tmux new-session -d"
      # This setting provides a more fine grain option over the creation of the
      # systemd unit.
      #
      # Having said all that, it is important to understand that systemd units
      # are defined as .nix settings and then created when NixOS is built and
      # nothing is generated "willy-nilly" by applications.
      # So this aspect of the plugin is already taken care of by me in a separate
      # systemd unit that is responsible to start tmux when system starts.
      #
      # set -g @continuum-save-interval is written into the status-right which
      # means that any other plugin that writes into status-right needs to be
      # loaded first or the autosave functionality will not work.
      #
      # More then that it looks like the autosave feature(set -g @continuum-save-interval)
      # only works if you are attached to tmux, for some reason it does not work
      # in detached mode. Maybe if no one is attached then there is nothing
      # changing and so nothing to save.
      #
      # If autosave option interval is not set there is a default of 15 minutes
      # and it worked for me when tested.
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5'
        '';
      }
      # {
      #   plugin = tmuxPlugins.catppuccin;
      #   extraConfig = ''
      #   # capatuine theme
      #   set -g @catppuccin_flavour "mocha"

      #   set -g @catppuccin_window_left_separator "█"
      #   set -g @catppuccin_window_right_separator "█ "
      #   set -g @catppuccin_window_number_position "right"
      #   set -g @catppuccin_window_middle_separator "  █"
      #
      #   set -g @catppuccin_window_default_fill "number"
      #
      #   set -g @catppuccin_window_current_fill "number"
      #   set -g @catppuccin_window_current_text "#{pane_current_path}"
      #
      #   # set -g @catppuccin_status_modules_right "application session date_time"
      #   set -g @catppuccin_status_left_separator  ""
      #   set -g @catppuccin_status_right_separator " "
      #   set -g @catppuccin_status_fill "all"
      #   set -g @catppuccin_status_connect_separator "yes"
      #   '';
      # }
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
    ];
    extraConfig = ''
      # Saving right after fresh install on first boot of the tmux daemon with no sessions will create an
      # empty "last" session file which might cause all kind of issues if tmux gets restarted before
      # the user had the chance to work in it and let continuum plugin to take over and create
      # at least one valid "snapshot" from which tmux will be able to resurrect. This is why an initial
      # session named init-resurrect is created for resurrect plugin to create a valid "last" file for
      # continuum plugin to work off of.
      #  run-shell "if [ ! -d ~/.config/tmux/resurrect ]; then tmux new-session -d -s init-resurrect; ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh; fi"

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
}
