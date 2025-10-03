{
  pkgs,
  lib,
  config,
  ...
}: let
  homeDir = "${config.home.homeDirectory}";
in {
  home.activation.cloneOrUpdateFlakeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    function cloneOrUpdateFlakeConfig {
      local config_dir="${homeDir}/.config/flake"
      local repo_url="https://github.com/akibahmed229/nixos.git"
      local git="${pkgs.git}/bin/git"

      if [[ ! -d "$config_dir" ]]; then
        echo "Cloning NixOS config to $config_dir..."
        mkdir -p "$config_dir"
        "$git" clone "$repo_url" "$config_dir" --depth 1
      else
        echo "Checking and updating NixOS config in $config_dir..."

        # wrapped in a subshell (...). This ensures that any change in directory or potential script failure doesn't affect the rest of the Home Manager activation script.
        (
          cd "$config_dir" || exit 1
          if "$git" rev-parse --is-inside-work-tree >/dev/null 2>&1; then

            # Check if the repository is clean (no uncommitted changes)
            if [[ -z $("$git" status -s) ]]; then
              echo "Repository is clean. Pulling latest changes..."
              "$git" pull --ff-only
            else
              echo "Warning: Repository is NOT clean. Skipping automated git pull to preserve local changes."
            fi

          else
            echo "Warning: $config_dir exists but is not a git repository. Skipping update."
          fi
        )
      fi
    }
    cloneOrUpdateFlakeConfig
  '';
}
