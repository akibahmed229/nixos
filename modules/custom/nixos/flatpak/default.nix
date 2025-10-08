# Configures the Flatpak service and uses an activation script to
# declaratively manage the list of desired Flatpak applications.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.flatpak;

  # Format the list of apps into a shell array string
  flatpakAppsShellArray = builtins.concatStringsSep "\n" (
    map (app: ''"${app}"'') cfg.apps
  );
in {
  # --- 1. Define Options ---
  options.nm.flatpak = {
    enable = mkEnableOption "Enable and configure the Flatpak service.";

    apps = {
      enable = mkEnableOption "Enable Flatpak service to manage applications.";
      lists = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          A list of Flatpak application IDs (e.g., "org.telegram.desktop") that should be installed and managed.
          The activation script ensures only apps in this list are installed.
        '';
        example = [
          "com.google.Chrome"
          "md.obsidian.Obsidian"
          "org.telegram.desktop"
        ];
      };
    };
  };

  /*
    # Example usage
  ```nix
    nm.flatpak = {
      enable = true;

      # Easily manage the list of all desired applications here
      apps = {
        enable = true;
        lists = [
          "sh.ppy.osu"
          "com.jgraph.drawio.desktop"
          "com.github.tchx84.Flatseal"
          "com.google.Chrome"
          "md.obsidian.Obsidian"
          "org.telegram.desktop"
          "org.mozilla.firefox"
          "org.qbittorrent.qBittorrent"
          "io.github.Figma_Linux.figma_linux"
        ];
      };
    };
  ```
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # Enable the core Flatpak service
    services.flatpak.enable = true;

    # Inject the management script into the system activation phase
    system.activationScripts = mkIf cfg.apps.enable {
      flatpak = {
        # Ensure the script runs *after* basic file systems are set up
        # We give it a high priority (20) to ensure it runs
        text = ''
          echo "=> Managing Flatpak applications..."

          # Define the target list of desired flatpaks
          flatpaks=(
            ${flatpakAppsShellArray}
          )

          # Add Flathub remote if it doesn't exist
          ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

          # --- Installation Loop: Install missing packages ---
          for package in ''${flatpaks[*]}; do
            # Check if the package is already installed
            check=$(${pkgs.flatpak}/bin/flatpak list --app | ${pkgs.gnugrep}/bin/grep -E "\s$package\s")
            if [[ -z "$check" ]] then
              echo "Installing missing flatpak: $package"
              ${pkgs.flatpak}/bin/flatpak install -y flathub $package || true
            fi
          done

          # --- Uninstallation Loop: Remove unwanted packages ---

          # 1. Get a list of *currently installed* application IDs
          installed=($(${pkgs.flatpak}/bin/flatpak list --app | ${pkgs.gawk}/bin/awk '{print $2}'))

          # 2. Iterate over installed applications
          for remove in ''${installed[*]}; do
            # Check if the installed app is NOT in the desired list ($flatpaks)
            # The outer spaces ensure we match the full application ID
            if [[ ! " ''${flatpaks[*]} " =~ " ''${remove} " ]]; then
              echo "Uninstalling unwanted flatpak: $remove"
              ${pkgs.flatpak}/bin/flatpak uninstall -y $remove || true
            fi
          done

          # Clean up unused runtimes and dependencies
          ${pkgs.flatpak}/bin/flatpak uninstall -y --unused || true

          echo "=> Flatpak management complete."
        '';
      };
    };
  };
}
