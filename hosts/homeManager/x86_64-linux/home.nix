# common home-manager configuration across all machines
# run `man home-configuration.nix` to view the documentation.
{
  user,
  pkgs,
  state-version,
  self,
  lib,
  config,
  ...
}: {
  imports = [
    self.homeModules.default # Custom home-manager modules
  ];

  targets.genericLinux.enable = true;

  home.activation = {
    myBackupScript = lib.hm.dag.entryAfter ["checkFilesChanged"] ''
      # Custom backup logic if needed
      for f in ~/.bashrc ~/.zshrc ~/.config/systemd/user/tmux.service; do
        if [ -f "$f" ]; then
          mv "$f" "$f.hm-bak"
        fi
      done
    '';
  };

  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "${user}";
    homeDirectory = "/home/${user}";

    shell.enableZshIntegration = true;
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "${state-version}"; # Please read the comment before changing.
  };

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

  # Set up nix for flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      accept-flake-config = true # Enable substitution from flake.nix
      trusted-users = ${config.home.username}
    '';
    package = pkgs.nix;

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  services.home-manager.autoUpgrade.frequency = "weekly";
}
