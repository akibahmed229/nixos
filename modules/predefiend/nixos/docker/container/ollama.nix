{
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      ollama = {
        image = "ollama/ollama";
        ports = ["11434:11434"];
        volumes = [
          "ollama:/root/.ollama"
        ];
        autoStart = true;
      };

      ollama-webui = {
        image = "ghcr.io/open-webui/open-webui:main";
        ports = ["4801:8080"];
        environment = {
          OLLAMA_BASE_URL = "http://localhost:11434"; # Points to Ollama container
        };
        volumes = [
          "ollama-webui:/app/backend/data"
        ];
        extraOptions = [
          "--link=ollama:ollama"
        ];
        autoStart = true;
      };
    };
  };
}
