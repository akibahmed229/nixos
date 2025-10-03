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
      local secret_dir="${homeDir}/.config/flake/modules/predefiend/nixos/sops/config"
      local git="${pkgs.git}/bin/git"
      local ssh="${pkgs.openssh}/bin/ssh"

      # ========================================================================
      # 1. INITIAL CLONE (if directory doesn't exist)
      # ========================================================================
      if [[ ! -d "$config_dir" ]]; then
        echo "Cloning NixOS config to $config_dir..."
        mkdir -p "$config_dir"

        # --- Attempt Private (SSH) Clone First ---
        if "$ssh" -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
          echo "SSH authentication successful. Cloning via SSH (Private/Full)."

          # Clone the main repo (use --recursive if secrets is a submodule)
          "$git" clone -o github --recursive git@github.com:akibahmed229/nixos.git "$config_dir"

          # Attempt GitLab setup (secrets repo)
          if "$ssh" -T git@gitlab.com 2>&1 | grep -q "Welcome to GitLab"; then

            (
              # Set up secrets directory and clone the secrets repo
              echo "Cloning private secrets repo from GitLab..."
              mkdir -p "$secret_dir"
              cd "$secret_dir" || exit 1
              "$git" clone git@gitlab.com:akibahmed/sops-secrects.git . || true
            )

            (
              # Add the gitlab remote to the main repo for potential syncs
              cd "$config_dir" || exit 1
              "$git" remote add gitlab git@gitlab.com:akibahmed/nixos.git || true
            )
          fi

        # --- Fallback to Public (HTTPS) Clone ---
        else
          echo "SSH authentication failed or not configured. Cloning via HTTPS (Public/Minimal)."
          "$git" clone "$repo_url" "$config_dir" --depth 1
        fi

      # ========================================================================
      # 2. UPDATE EXISTING REPO (if directory exists)
      # ========================================================================
      else
        echo "Checking and updating NixOS config in $config_dir..."

        (
          cd "$config_dir" || exit 1
          if "$git" rev-parse --is-inside-work-tree >/dev/null 2>&1; then

            # 1. Check if the repository is clean (SAFETY CHECK)
            if [[ -z $("$git" status -s) ]]; then
              echo "Repository is clean. Pulling latest changes..."
              "$git" pull --ff-only

              # 2. Update submodules after the main repo pull
              echo "Updating submodules..."
              "$git" submodule update --init --recursive --remote

              # 3. CRITICAL FIX: Update the separate secrets repo
              if [[ -d "$secret_dir" ]]; then
                echo "Pulling latest secrets from GitLab..."
                (
                  cd "$secret_dir" || exit 1
                  if "$git" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                    "$git" pull --ff-only
                  else
                    echo "Warning: Secrets directory is not a git repo. Skipping pull."
                  fi
                )
              fi

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
