# This module deploys the Ollama LLM service and optionally the Open WebUI frontend.
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nm.docker.container.ollama;
in {
  # --- 1. Define Options ---
  options.nm.docker.container.ollama = {
    enable = mkEnableOption "Enable the Ollama large language model service via Docker container";
    enablePort = mkEnableOption "Enable the Ollama Service Port to Access in Local Network";

    image = mkOption {
      type = types.str;
      default = "ollama/ollama";
      description = "The Docker image for the Ollama service.";
    };

    hostPort = mkOption {
      type = types.int;
      default = 11434;
      description = "Host port exposed for the Ollama API (maps to container port 11434).";
    };

    dataPath = mkOption {
      type = types.str;
      default = "/var/lib/ollama";
      description = "Host path for Ollama models and data persistence (/root/.ollama).";
    };

    # Open WebUI Options
    enableWebUI = mkEnableOption "Enable the Open WebUI frontend for Ollama";

    webUIImage = mkOption {
      type = types.str;
      default = "ghcr.io/open-webui/open-webui:main";
      description = "The Docker image for Open WebUI.";
    };

    webUIHostPort = mkOption {
      type = types.int;
      default = 4801;
      description = "Host port exposed for the WebUI (maps to container port 8080).";
    };

    webuiDataPath = mkOption {
      type = types.str;
      default = "/var/lib/ollama-webui";
      description = "Host path for WebUI data persistence (/app/backend/data).";
    };
  };

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 Container Definitions
    virtualisation.oci-containers = {
      backend = "docker";

      containers =
        {
          # Ollama Service (LLM Engine)
          ollama = {
            image = cfg.image;
            ports = [
              "${toString cfg.hostPort}:11434" # Ollama API Port
            ];
            volumes = [
              "${cfg.dataPath}:/root/.ollama" # Persistence for models
            ];
            autoStart = true;
          };
        }
        // (optionalAttrs cfg.enableWebUI {
          # Open WebUI Frontend (Conditionally Included)
          ollama-webui = {
            image = cfg.webUIImage;
            ports = ["${toString cfg.webUIHostPort}:8080"];
            environment = {
              # REFECTOR: Use the container name 'ollama' as the hostname for internal communication
              OLLAMA_BASE_URL = "http://ollama:11434";
            };
            volumes = [
              "${cfg.webuiDataPath}:/app/backend/data"
            ];
            extraOptions = [
              # Link the ollama container to the webui container
              "--link=ollama:ollama"
            ];
            # Ensure Ollama is started before the WebUI attempts to connect
            dependsOn = ["ollama"];
            autoStart = true;
          };
        });
    };

    # 2.2 Open the required ports in the host firewall
    networking.firewall.allowedTCPPorts =
      optional cfg.enablePort
      ([
          cfg.hostPort # Ollama API
        ]
        ++ (optional cfg.enableWebUI cfg.webUIHostPort));
  };
}
