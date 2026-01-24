# modules/ngrok.nix
# Configures ngrok as systemd services to create tunnels for local services,
# dynamically reading the target URL/domain from a file (e.g., a secret file).
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.ngrok;

  # Function to map the list of tunnel configurations to systemd service definitions
  ngrokServices = builtins.listToAttrs (map (tunnel: {
      # The service name is used as the key for systemd.services
      name = tunnel.serviceName;
      value = {
        description = "ngrok tunnel for ${tunnel.serviceName}";
        wantedBy = ["multi-user.target"];

        # Dependency management: wait for and require the upstream service
        after = ["${tunnel.dependsOnService}"];
        requires = ["${tunnel.dependsOnService}"];

        serviceConfig = {
          # ExecStart dynamically constructs the ngrok command
          ExecStart = "${pkgs.ngrok}/bin/ngrok http --url=$(cat ${tunnel.domainFile}) ${toString tunnel.targetPort}";
          Restart = "on-failure";
          PermissionsStartOnly = true;
          User = tunnel.runAsUser;
          RemainAfterExit = true;
        };
      };
    })
    cfg.tunnels);
in {
  # --- 1. Define Options ---
  options.nm.ngrok = {
    enable = mkEnableOption "Enable ngrok service configuration.";

    tunnels = mkOption {
      type = types.listOf (types.submodule ({...}: {
        options = {
          serviceName = mkOption {
            type = types.str;
            description = "The name of the generated systemd service (e.g., 'ngrok-n8n').";
          };
          domainFile = mkOption {
            type = types.path;
            description = "Path to the file containing the domain/URL to tunnel (e.g., from inputs.secrets).";
          };
          targetPort = mkOption {
            type = types.int;
            default = 5678;
            description = "The local port of the service to tunnel.";
          };
          dependsOnService = mkOption {
            type = types.str;
            default = "multi-user.target";
            description = "The systemd service that ngrok must wait for and require.";
          };
          runAsUser = mkOption {
            type = types.str;
            default = "root";
            description = "The user to run the ngrok service as.";
          };
        };
      }));
      default = [];
      description = "List of ngrok tunnels to configure as systemd services.";
    };
  };

  /*
  # Example usage of this module
  ngrok = {
    enable = true;
    tunnels = let
      secretsInput = builtins.toString inputs.secrets;
    in [
      {
        serviceName = "ngrok_n8n";
        targetPort = 5678;
        domainFile = "${secretsInput}/ngrok/domain.txt";
        dependsOnService = "docker-n8n.service";
        runAsUser = user; # Use the user variable passed to your configuration
      }
      # You can define more tunnels here, e.g., for a web server:
      # {
      #   serviceName = "ngrok_web";
      #   targetPort = 80;
      #   domainFile = "${secretsInput}/ngrok/web_domain.txt";
      #   dependsOnService = "nginx.service";
      #   runAsUser = "webuser";
      # }
    ];
  };
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.ngrok];

    # Apply the generated services
    systemd.services = ngrokServices;
  };
}
