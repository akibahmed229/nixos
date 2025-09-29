{
  pkgs,
  user,
  self,
  ...
}: let
  inherit (self.lib) mkImport mkRelativeToRoot;
in {
  # imports from the predefiend modules folder
  imports = mkImport {
    path = mkRelativeToRoot "modules/predefiend/home-manager";
    ListOfPrograms = [
      "zsh"
      "starship"
      "tmux"
      "yazi"
      "atuin"
      "direnv"
      "fastfetch"
      "nvim"
    ];
  };

  # ── Meta ─────────────────────────────────────────────────────────────────────
  # Let Home Manager manage itself.
  programs.home-manager.enable = true;

  # Set your username and home directory.
  home.username = user;
  home.homeDirectory = "/Users/${user}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards-incompatible changes.
  #
  # You should update this value BEFORE you update Home Manager.
  home.stateVersion = "24.05";

  # ── Packages ─────────────────────────────────────────────────────────────────
  # Install personal command-line packages here.
  home.packages = with pkgs; [
    # Development
    lazygit
    ripgrep # A better grep
    fd # A better find

    # Shell tools
    eza # A modern `ls`
    bat # A modern `cat` with syntax highlighting
    zoxide # A smarter `cd` command

    # Utilities
    htop # System monitor
    tldr # Simplified man pages
    jq # JSON processor
  ];

  # ── Dotfiles & Programs ──────────────────────────────────────────────────────
  # You can manage your dotfiles and configure programs here.

  # Configure Git with your personal details.
  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };

  # An example of linking a file from your flake into your home directory.
  # This is the best way to manage entire config directories.
  # For this to work, you would create a file at:
  #   .../akibs-iMac-Pro.local/config/starship.toml
  #
  # xdg.configFile."starship.toml".source = ./config/starship.toml;

  # Set environment variables.
  home.sessionVariables = {
    EDITOR = "nvim";
    LANG = "en_US.UTF-8";
  };
}
