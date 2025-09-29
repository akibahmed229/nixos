{
  pkgs,
  state-version,
  user,
  ...
}: {
  # It's crucial to set this.
  system.stateVersion = state-version;

  # ── Global Settings ──────────────────────────────────────────────────────────
  # System-wide settings and packages.

  # Enable flakes and the new nix command.
  nix = {
    enable = false;
    settings = {
      # given the users in this list the right to specify additional substituters via:
      #    1. `nixConfig.substituters` in `flake.nix`
      trusted-users = [user];

      experimental-features = ["nix-command" "flakes"];
    };
  };

  # Set your timezone.
  time.timeZone = "Asia/Dhaka";

  # Install some essential command-line tools.
  environment.systemPackages = with pkgs; [
    git
    coreutils # Provides GNU utilities like `gsha256sum`
    wget
    neovim
  ];

  # ── User Environment ─────────────────────────────────────────────────────────
  # Define default settings for users.

  # ── Homebrew ─────────────────────────────────────────────────────────────────
  # Enable and configure Homebrew for GUI apps (casks) and CLI tools (brews).
  # This is managed by Nix, so you don't need to run `brew` commands manually.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # Thoroughly uninstall old versions
    };
    # You can add common brews/casks for all your Macs here.
    # For example:
    # taps = [ "homebrew/cask-fonts" ];
    # brews = [ "htop" ];
    # casks = [ "font-fira-code-nerd-font" ];
  };

  # ── Security ─────────────────────────────────────────────────────────────────

  # You can add more security settings here.
  # For example, to enable Gatekeeper:
  # security.gatekeeper.enable = true;
}
