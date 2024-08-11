# common home-manager configuration across all machines
# run `man home-configuration.nix` to view the documentation.
{
  user,
  state-version,
  theme,
  self,
  ...
}: let
  inherit (self.lib) mkRelativeToRoot;
in {
  imports = [
    self.homeManagerModules.default # Custom home-manager modules
  ];

  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "${user}";
    homeDirectory = "/home/${user}";

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
    ".config/gtk-4.0" = {
      source = mkRelativeToRoot "public/themes/gtk/${theme}";
      recursive = true;
    };
    ".config/gtk-3.0" = {
      source = mkRelativeToRoot "public/themes/gtk/${theme}";
      recursive = true;
    };
    ".config/gtk-2.0" = {
      source = mkRelativeToRoot "public/themes/gtk/${theme}";
      recursive = true;
    };

    # The camera's /dev/video file is kept open (without streaming), sadly causing the camera to be powered on what looks to be most devices.
    # For some reason, this completely nullifies the soc power management on modern laptops and can result in increases from 3W to 8W at idle!
    ".config/wireplumber" = {
      source = mkRelativeToRoot "modules/predefiend/home-manager/wireplumber"; # tells wireplumber to ignore cameras
      recursive = true;
    };
  };

  # GTK and QT themes ( custom home-manager module )
  theme.enable = true;

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
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
