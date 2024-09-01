{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "toggleRGB";

  runtimeInputs = with pkgs; [openrgb gnugrep];

  text = ''
    #!/usr/bin/env bash

    # State file to store the current toggle state
    STATE_FILE="/tmp/rgb_state"

    # Initialize state if it doesn't exist
    if [ ! -f "$STATE_FILE" ]; then
      echo "off" > "$STATE_FILE"
    fi

    # Read the current state
    CURRENT_STATE=$(cat "$STATE_FILE")

    # No rgb
    NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | ${pkgs.gnugrep}/bin/grep -E '^[0-9]+: ' | wc -l)

    if [ "$CURRENT_STATE" == "off" ]; then
      # Turn RGB on
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --mode static --color FF0000 # Example: Red color
      echo "on" > "$STATE_FILE"
    else
      # Turn RGB off
      for i in $(seq 0 $(("$NUM_DEVICES" - 1))); do
        ${pkgs.openrgb}/bin/openrgb --noautoconnect --device "$i" --mode static --color 000000
      done
      echo "off" > "$STATE_FILE"
    fi
  '';
}
