{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "loginDE";

  # We need these tools at runtime
  runtimeInputs = with pkgs; [
    fzf # For the selection menu
    gawk # For parsing text
    findutils # For finding .desktop files
    coreutils # For cat, cut, etc.
  ];

  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    # --- Configuration ---
    SESSION_DIRS=(
      "/run/current-system/sw/share/wayland-sessions"
      "/run/current-system/sw/share/xsessions"
      "$HOME/.nix-profile/share/wayland-sessions"
    )

    # --- 1. User Selection ---
    # Only ask for user if we are essentially root or a dedicated greeter.
    # Otherwise, assume the current logged-in user.
    CURRENT_USER=$(whoami)

    if [ "$CURRENT_USER" == "root" ] || [ "$CURRENT_USER" == "greeter" ]; then
        echo "Select User:"
        # List users with UID >= 1000 (standard users)
        SELECTED_USER=$(awk -F':' '$3 >= 1000 && $3 < 30000 {print $1}' /etc/passwd | fzf --prompt="User > " --height=10 --reverse)

        if [ -z "$SELECTED_USER" ]; then echo "No user selected. Exiting."; exit 1; fi
    else
        echo "Logged in as: $CURRENT_USER"
        SELECTED_USER="$CURRENT_USER"
    fi

    # --- 2. Desktop Environment Selection ---
    echo "Scanning for Desktop Environments..."

    # Create a temporary file to store available sessions
    SESSIONS_FILE=$(mktemp)

    # Iterate through known session directories
    for dir in "''${SESSION_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -name "*.desktop" -print0 | while IFS= read -r -d "" file; do
                # Extract Name and Exec command
                NAME=$(grep "^Name=" "$file" | head -n 1 | cut -d= -f2-)
                EXEC=$(grep "^Exec=" "$file" | head -n 1 | cut -d= -f2-)
                TYPE=$(basename "$(dirname "$dir")") # wayland-sessions or xsessions

                if [ -n "$NAME" ] && [ -n "$EXEC" ]; then
                    echo "$NAME ($TYPE) | $EXEC" >> "$SESSIONS_FILE"
                fi
            done
        fi
    done

    # Fallback: If no sessions found (common in custom NixOS setups without DM),
    # manually check for Niri or generic shell
    if [ ! -s "$SESSIONS_FILE" ]; then
        if command -v niri-session >/dev/null; then echo "Niri (Fallback) | niri-session" >> "$SESSIONS_FILE"; fi
        echo "Bash Shell (Fallback) | bash" >> "$SESSIONS_FILE"
    fi

    # Show Menu
    echo "Select Desktop Environment:"
    SELECTION=$(cat "$SESSIONS_FILE" | fzf --prompt="Session > " --height=10 --reverse --with-nth=1 --delimiter="|")

    # Cleanup
    rm -f "$SESSIONS_FILE"

    if [ -z "$SELECTION" ]; then
        echo "No session selected. Dropping to shell."
        exit 0
    fi

    # Extract the command (everything after the | separator)
    CMD=$(echo "$SELECTION" | awk -F'|' '{print $2}' | xargs)


    # --- 3. Launch the Session ---

    echo "Starting $SELECTED_USER session: $CMD"

    # Define the launcher function
    launch_session() {
        # Export necessary variables for Wayland/Niri
        export XDG_SESSION_TYPE=wayland
        export XDG_CURRENT_DESKTOP=niri # Adjust logic if you use multiple DEs dynamically

        # dbus-run-session is critical for starting a session from TTY
        # exec replaces the current shell so we don't have a lingering bash process
        exec dbus-run-session $1
    }

    # If we need to switch users (e.g. running as root)
    if [ "$CURRENT_USER" != "$SELECTED_USER" ]; then
        # Use runuser or su to switch and launch
        # Note: This might require password input depending on PAM/sudoers
        exec su - "$SELECTED_USER" -c "dbus-run-session $CMD"
    else
        # Running as the correct user already
        launch_session "$CMD"
    fi
  '';
}
