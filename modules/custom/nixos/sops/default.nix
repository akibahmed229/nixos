# Configures system-wide secret management using SOPS and sops-nix.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.sops;
in {
  /*
  * useful resources: https://unmovedcentre.com/posts/secrets-management/#using-nix-secrets-with-nix-config
  * Secrets management with SOPS and Nix
  * System level secrets

  * Create a age key
  * mkdur -p ~/.config/sops/age
  * age-keygen -o ~/.config/sops/age/keys.txt

  * This will generateKey age key using ssh-to-age for each host key in sshKeyPaths
  * nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'

  * update changes .sops.yaml file like adding age key, removing old keys etc
  * sops updatekeys secrets.yaml
  */

  # --- 0. Imports ---
  #imports = [
  #  inputs.sops-nix.nixosModules.sops
  #];

  # --- 1. Define Options ---
  options.nm.sops = {
    enable = mkEnableOption "Enable and configure system-level secret management via sops-nix.";

    defaultSopsFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The path to the default encrypted secrets file (e.g., secrets.yaml).";
    };

    defaultSopsFormat = mkOption {
      type = types.str;
      default = "yaml";
      description = "The default file format for SOPS secrets.";
    };

    # Age Key Configuration
    age = {
      keyFile = mkOption {
        type = types.str;
        default = "/var/lib/sops-nix/keys.txt";
        description = "Path to the age key file used for decryption.";
      };

      generateKey = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to generate a new key if the keyFile does not exist.";
      };

      sshKeyPaths = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of SSH host key paths to automatically import as age keys.";
      };
    };

    # Secret Definitions (Allows merging of secret sets from different configs)
    secrets = mkOption {
      # Use attrsOf unspecified to allow full flexibility for upstream sops.secrets options
      type = types.attrsOf types.unspecified;
      default = {};
      description = ''
        An attribute set defining secrets. Attributes added here will be merged
        with other definitions across the system.
        Example: { "my/secret" = { neededForUsers = true; }; }
      '';
    };
  };

  /*
  # Example of usage
    ```nix
      nm.sops = {
        enable = true;

        # 2. Define the user-specific primary secrets file path
        defaultSopsFile = "${secretsInput}/secrets/secrets.yaml"; # Note: Replace this with the path appropriate for this host/user

        # 3. Define the secrets needed for this host/user.
        # These definitions will be merged across all modules that configure nm.sops.secrets.
        secrets = {
          "akib/password/root_secret".neededForUsers = true;
          "akib/password/my_secret".neededForUsers = true;
          "akib/wireguard/PrivateKey".neededForUsers = true;
          "akib/cloudflared".neededForUsers = true;
          "afif/password/my_secret".neededForUsers = true;
          # You can now add system secrets specific to this host easily:
          "host/my_service_token".path = "/run/secrets/service_token";
        };
      };
    ```
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    sops = {
      defaultSopsFormat = cfg.defaultSopsFormat;

      # Conditionally set the defaultSopsFile if the user provides one
      defaultSopsFile = lib.optionalString (cfg.defaultSopsFile != null) cfg.defaultSopsFile;

      age = {
        keyFile = cfg.age.keyFile;
        generateKey = cfg.age.generateKey;
        sshKeyPaths = cfg.age.sshKeyPaths;
      };

      /*
      * secrets will be outputs to /run/secrets
      * eg. /run/secrets/my_secret
      * secrets required for user creation are handled in respective ./users/<username>.nix files
      * because they will be out to /run/secrets-for-users and only when the user is assigned to a host.
      */

      # Merge all secret definitions provided via the module option
      secrets = cfg.secrets; # decrypt the secret to /run/secrets-for-users
    };

    # Install necessary packages for manual secret management
    environment.systemPackages = with pkgs; [sops age];
  };
}
