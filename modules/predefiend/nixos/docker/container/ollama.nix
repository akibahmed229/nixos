{
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      ollama-webui = {
        image = "ghcr.io/open-webui/open-webui:main";
        ports = ["4801:8080"];
        environment = {
          OLLAMA_BASE_URL = "http://localhost:11434"; # Points to Ollama container
        };
        volumes = [
          "/var/lib/ollama-webui:/app/backend/data"
        ];
        extraOptions = [
          "--link=ollama:ollama"
        ];
        autoStart = true;
      };

      ollama = {
        image = "ollama/ollama";
        ports = ["11434:11434"];
        volumes = [
          "/var/lib/ollama:/root/.ollama"
        ];
        autoStart = true;
      };
    };
  };
}
