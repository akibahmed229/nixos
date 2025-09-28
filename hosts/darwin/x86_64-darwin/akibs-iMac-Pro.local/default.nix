{user, ...}: {
  # Import the base Darwin configuration.
  imports = [
    ../configuration.nix
  ];

  # ── Host-Specific Settings ───────────────────────────────────────────────────

  # Set the hostname and computer name.
  networking.hostName = "akibs-imac-pro";
  system.computerName = "Akib's iMac Pro";

  # ── User Account ─────────────────────────────────────────────────────────────
  # Define your user account on this machine.
  # Replace 'akib' with your actual username if it's different.
  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
    # You can add groups here if needed, e.g.:
    extraGroups = ["admin" "wheel"];
  };

  # ── Home Manager Setup ───────────────────────────────────────────────────────
  # Integrate Home Manager for this user.
  # This assumes you have home-manager as an input in your flake.
  home-manager = {
    users.${user} = import ./home.nix; # Points to your user-specific dotfiles config
  };

  # ── GUI Applications via Homebrew Casks ──────────────────────────────────────
  # Install applications that are specific to this iMac.
  homebrew.casks = [
    "firefox"
    "visual-studio-code"
    "iterm2"
    "spotify"
    "discord"
    "rectangle" # A great window manager
  ];

  # You can also install specific command-line tools for this machine.
  # homebrew.brews = [ "imagemagick" ];
}
