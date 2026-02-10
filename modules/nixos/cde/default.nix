{pkgs, ...}: let
  loginDE = pkgs.writeShellScriptBin "loginDE" ''
    set -euo pipefail

    ${pkgs.ncurses}/bin/tput reset

    # 1. User Selection
    echo "Welcome to NixOS. Please select a user:"
    SELECTED_USER=$(${pkgs.gawk}/bin/awk -F':' '$3 >= 1000 && $3 < 30000 {print $1}' /etc/passwd | ${pkgs.fzf}/bin/fzf --prompt="User > " --height=10 --reverse)

    if [ -z "$SELECTED_USER" ]; then exit 1; fi

    # 2. Session Selection
    echo "Select session for $SELECTED_USER:"
    CHOICE=$(printf "Niri\nZsh\nBash" | ${pkgs.fzf}/bin/fzf --prompt="Session > " --height=10 --reverse)

    if [ -z "$CHOICE" ]; then exit 1; fi

    # 3. Store the choice (The Bridge)
    # We remove the old file first to solve the "Permission denied" error
    SESSION_FILE="/tmp/session_choice_$SELECTED_USER"
    rm -f "$SESSION_FILE"
    echo "$CHOICE" > "$SESSION_FILE"
    chown "$SELECTED_USER" "$SESSION_FILE"

    # 4. Hand over to 'login' for Password Authentication
    # This solves the orange systemd errors by initializing a proper session
    ${pkgs.ncurses}/bin/tput reset
    exec /run/current-system/sw/bin/login "$SELECTED_USER"
  '';
in {
  # Ensure dbus-run-session is available for the handover
  environment.systemPackages = [pkgs.dbus pkgs.niri];

  # --- Part 1: The Service (The Picker) ---
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  systemd.services.display-manager = {
    description = "Custom TTY Login Manager";
    after = ["systemd-user-sessions.service" "plymouth-quit-wait.service" "getty@tty1.service"];
    conflicts = ["getty@tty1.service"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${loginDE}/bin/loginDE";
      StandardInput = "tty";
      StandardOutput = "tty";
      TTYPath = "/dev/tty1";
      TTYReset = "yes";
      TTYVHangup = "yes";
      Restart = "always";
    };
    wantedBy = ["graphical.target"];
  };

  # --- Part 2: The Launcher (The Puzzle Solver) ---
  # This runs after you successfully type your password
  environment.loginShellInit = ''
    if [[ "$(tty)" == "/dev/tty1" ]]; then
      SESSION_FILE="/tmp/session_choice_$(whoami)"
      if [[ -f "$SESSION_FILE" ]]; then
        CHOICE=$(cat "$SESSION_FILE")
        rm -f "$SESSION_FILE" # Clean up immediately

        case "$CHOICE" in
          "Niri")
            exec niri-session
            ;;
          "Bash")
            exec bash
            ;;
          "Zsh")
            # Just let the login shell continue
            ;;
        esac
      fi
    fi
  '';
}
