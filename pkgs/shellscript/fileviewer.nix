{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellScriptBin "fileviewer" ''
  #!/usr/bin/env bash
  # This script is used to find files in the current directory and its subdirectories 

  # Function to find files using fzf and preview them
  akibFind() {
    # Start an infinite loop for continuous file search
    while true; do
      # Use fzf to search for files in the current directory
      selection="$(ls -a | ${pkgs.fzf}/bin/fzf \
        --reverse --height 95% --border "bold" --inline-info \
        --prompt "Search: " --border-label "$(pwd)/" \
        --bind "left:pos(2)+accept" --bind "right:accept" \
        --bind "shift-up:preview-up" --bind "shift-down:preview-down" \
        --preview-window=right:60% --preview 'cd_previ="$(echo $(pwd)/$(echo {}))";
               echo "Directory: $cd_previ";
               echo;
               ls -a "$cd_previ";
               if [[ -f {} ]]; then
                 file_type="$(${pkgs.file}/bin/file --mime-type -b {})";
                 if [[ "$file_type" == "text/plain" ]]; then
                   ${pkgs.bat}/bin/bat --style=numbers --theme=ansi --color=always {} 2>/dev/null
                 else 
                   ${pkgs.chafa}/bin/chafa -c full --color-space rgb --dither none -p on -w 9 2>/dev/null {}
                 fi
               else
                 echo "Not a regular file"
               fi')" 
      # If the selection is a directory, change directory to it
      if [[ -d $selection ]]; then
        >/dev/null cd "$selection"
      else
        # Break the loop if a file is selected
        break
      fi
    done
  }

  # Clear the terminal screen
  clear
  # Call the function to start searching for files
  akibFind
''
