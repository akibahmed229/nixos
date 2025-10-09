# /etc/nixos/modules/cloudflared.nix
#
# This module provides a declarative way to configure and manage
# one or more Cloudflare Tunnels (cloudflared).
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Short-hand for the configuration options of this module.
  cfg = config.nm.cloudflared;

  # Define the structure for a single tunnel configuration.
  # This will be used in the `attrsOf` type below.
  tunnelModule = {name, ...}: {
    options = with lib; {
      tokenFile = mkOption {
        type = types.path;
        description = "Absolute path to the file containing the Cloudflare tunnel token.";
        example = "/run/secrets/cf-tunnel-token";
      };

      user = mkOption {
        type = types.str;
        default = "root";
        description = "The user to run the tunnel service as.";
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["--no-autoupdate" "--protocol" "quic"];
        description = "Extra arguments to pass to the 'cloudflared tunnel run' command.";
      };
    };
  };
in {
  options.nm.cloudflared = with lib; {
    enable = mkEnableOption "Cloudflare Tunnels (cloudflared)";

    package = mkOption {
      type = types.package;
      default = pkgs.cloudflared;
      defaultText = literalExpression "pkgs.cloudflared";
      description = "The cloudflared package to use.";
    };

    tunnels = mkOption {
      type = types.attrsOf (types.submodule tunnelModule);
      default = {};
      description = "Declarative configuration for one or more Cloudflare tunnels.";
      example = literalExpression ''
        {
          my-first-tunnel = {
            tokenFile = "/path/to/my-first-tunnel-token";
          };
          another-tunnel = {
            tokenFile = "/path/to/another-tunnel-token";
            user = "nobody";
            extraArgs = [ "--no-autoupdate" "--loglevel" "debug" ];
          };
        }
      '';
    };
  };

  /*
  # Example Usage
  ```nix
    nm.cloudflared = {
      enable = true;
      tunnels = {
        # This key "my-tunnel" will be part of the systemd service name (e.g., cloudflared-my-tunnel.service)
        my-tunnel = {
          # This points to the file containing your tunnel token.
          # It cleanly separates the configuration from the secret.
          tokenFile = "${builtins.toString inputs.secrets}/cloudflared/token";

          # The `user` and `extraArgs` options will use the defaults ("root"
          # and ["--no-autoupdate"]), which perfectly match your original config.
        };
      };
    };
  ```
  */

  config = lib.mkIf cfg.enable {
    # 1. Enable the base cloudflared service and add the package to the system.
    #    The base service is useful for CLI commands like `cloudflared tunnel login`.
    services.cloudflared = {
      enable = true;
      package = cfg.package;
    };

    environment.systemPackages = [cfg.package];

    # 2. Generate a systemd service for each tunnel defined in the options.
    systemd.services =
      lib.mapAttrs'
      (name: tunnel:
        lib.nameValuePair "cloudflared-${name}" {
          description = "Cloudflare Tunnel: ${name}";
          wantedBy = ["multi-user.target"];
          after = ["network-online.target"];
          requires = ["network-online.target"];

          serviceConfig = {
            Type = "simple";
            User = tunnel.user;
            ExecStart = let
              # Combine the extra arguments into a single string.
              argsStr = lib.concatStringsSep " " tunnel.extraArgs;
              token = lib.strings.trim (builtins.readFile "${tunnel.tokenFile}");
            in
              # The command reads the token from the specified file at runtime.
              "${cfg.package}/bin/cloudflared tunnel run ${argsStr} --token ${token}";
            Restart = "on-failure";
          };
        })
      cfg.tunnels;
  };
}
