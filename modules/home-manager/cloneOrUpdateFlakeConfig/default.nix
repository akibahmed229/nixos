{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hm.flake-sync;
in {
  options.hm.flake-sync = {
    enable = mkEnableOption "automated cloning and updating of the NixOS flake repository";

    path = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/flake";
      description = "The local directory where the flake should be cloned.";
    };

    repoUrl = mkOption {
      type = types.str;
      default = "https://github.com/akibahmed229/nixos.git";
      description = "The public HTTPS URL of the main repository.";
    };

    sshUrl = mkOption {
      type = types.str;
      default = "git@github.com:akibahmed229/nixos.git";
      description = "The private SSH URL of the main repository.";
    };

    secretsRepoUrl = mkOption {
      type = types.str;
      default = "git@gitlab.com:akibahmed/sops-secrects.git";
      description = "The private SSH URL of the secrets repository.";
    };

    secretsPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/flake/modules/nixos/sops/config";
      description = "Where the secrets repository should be cloned locally.";
    };
  };

  config = mkIf cfg.enable {
    home.activation.cloneOrUpdateFlakeConfig = hm.dag.entryAfter ["writeBoundary"] ''
      function cloneOrUpdateFlakeConfig {
        local config_dir="${cfg.path}"
        local repo_url="${cfg.repoUrl}"
        local ssh_url="${cfg.sshUrl}"
        local secret_dir="${cfg.secretsPath}"
        local secrets_repo="${cfg.secretsRepoUrl}"

        local git="${pkgs.git}/bin/git"
        local ssh="${pkgs.openssh}/bin/ssh"

        # 1. INITIAL CLONE
        if [[ ! -d "$config_dir" ]]; then
          echo "Sync: Target directory missing. Starting initial setup..."
          mkdir -p "$config_dir"

          # Attempt SSH
          if "$ssh" -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
            echo "Sync: SSH Auth OK. Cloning full private repo..."
            "$git" clone -o github --recursive "$ssh_url" "$config_dir"

            # Setup Secrets from GitLab
            if "$ssh" -T git@gitlab.com 2>&1 | grep -q "Welcome to GitLab"; then
              echo "Sync: GitLab Auth OK. Cloning secrets..."
              mkdir -p "$secret_dir"
              "$git" clone "$secrets_repo" "$secret_dir"

              # Add secondary remote for safety
              cd "$config_dir" && "$git" remote add gitlab git@gitlab.com:akibahmed/nixos.git || true
            fi
          else
            echo "Sync: SSH Auth Failed. Falling back to public HTTPS (shallow clone)..."
            "$git" clone "$repo_url" "$config_dir" --depth 1
          fi

        # 2. UPDATE EXISTING
        else
          echo "Sync: Checking for updates in $config_dir..."
          (
            cd "$config_dir" || exit 1
            if "$git" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              if [[ -z $("$git" status -s) ]]; then
                echo "Sync: Repo clean. Pulling main..."
                "$git" pull --ff-only
                "$git" submodule update --init --recursive --remote

                # Update secrets folder
                if [[ -d "$secret_dir" ]]; then
                  echo "Sync: Pulling latest secrets..."
                  (cd "$secret_dir" && "$git" pull --ff-only)
                fi
              else
                echo "Sync: Local changes detected. Skipping auto-pull to avoid conflicts."
              fi
            fi
          )
        fi
      }

      cloneOrUpdateFlakeConfig
    '';
  };
}
