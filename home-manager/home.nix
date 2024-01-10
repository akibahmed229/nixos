# common home-manager config accross all machines

{ config
, pkgs
, user
, state-version
, lib
, ...
}:

{

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "${state-version}"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    xdg-utils
    wl-clipboard
    tree
    bibata-cursors
    adw-gtk3
    gruvbox-dark-gtk
    gruvbox-dark-icons-gtk
    alacritty

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".config/alacritty/alacritty.yml" = {
      source = ../programs/alacritty/alacritty.yml;
      recursive = true;
    };
    ".config/OpenRGB" = {
      source = ../programs/OpenRGB;
      recursive = true;
    };
    ".config/neofetch" = {
      source = ../programs/neofetch;
      recursive = true;
    };
    ".ssh" = {
      source = ../programs/ssh;
      recursive = true;
    };
  };

  gtk = {
    enable = true;
    cursorTheme.name = "Bibata-Modern-Classic";
    cursorTheme.package = pkgs.bibata-cursors;
    theme.package = pkgs.adw-gtk3;
    theme.name = "adw-gtk3-dark";
    iconTheme.package = pkgs.gruvbox-dark-icons-gtk;
    iconTheme.name = "oomox-gruvbox-dark";
  };

  home = {
    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      size = 38;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };

  qt = {
    enable = true;
    # platform theme "gtk" or "gnome"
    platformTheme = "gtk3";
    # name of the qt theme
    style.name = "adwaita-dark";

    # detected automatically:
    # adwaita, adwaita-dark, adwaita-highcontrast,
    # adwaita-highcontrastinverse, breeze,
    # bb10bright, bb10dark, cde, cleanlooks,
    # gtk2, motif, plastique
    # package to use
    style.package = pkgs.adwaita-qt;
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/akib/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Tmux Config
  #programs.tmux = {
    enable = true;
    secureSocket = false;
    shell = "${pkgs.zsh}/bin/zsh"; # or zsh
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.catppuccin
      tmuxPlugins.gruvbox
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
          # I know of with set -g @resurrect-strategy-* I decided to keep it enabled for the time being.
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-strategy-vim 'session'

          set -g @resurrect-capture-pane-contents 'on'

          # This three lines are specific to NixOS and they are intended
          # to edit the tmux_resurrect_* files that are created when tmux
          # session is saved using the tmux-resurrect plugin. Without going
          # into too much details the strings that are saved for some applications
          # such as nvim, vim, man... when using NixOS, appimage, asdf-vm into the
          # tmux_resurrect_* files can't be parsed and restored. This addition
          # makes sure to fix the tmux_resurrect_* files so they can be parsed by
          # the tmux-resurrect plugin and successfully restored.
          set -g @resurrect-dir ${resurrectDirPath}
          set -g @resurrect-hook-post-save-all 'target=$(readlink -f ${resurrectDirPath}/last); sed "s| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g" $target | sponge $target'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
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
      run-shell "if [ ! -d ~/.config/tmux/resurrect ]; then tmux new-session -d -s init-resurrect; ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh; fi"

      source /home/${user}/flake/programs/tmux/tmux.conf
      '';
  };

  # NeoVim configuration
  # programs.neovim = {
  #  enable = true;
  #  defaultEditor = true;
  #  vimAlias = true;
  #  viAlias = true;

  #extraLuaConfig = ''
  #${builtins.filterSource (path: type: type == "regular") ../programs/nvim}
  #'';
  # #coc = {
  # #  enable = true;
  # #};
  ## configure = {
  ## customRC = '' 
  ## luafile ${./nvim/init.lua}
  ## '';
  ##  };
  #};

}
