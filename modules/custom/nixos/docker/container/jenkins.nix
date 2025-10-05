# This module deploys Jenkins (with Blue Ocean) alongside a Docker-in-Docker (Dind)
# sidecar, enabling Jenkins to execute Docker commands within pipelines.
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nm.docker.container.jenkins;
in {
  # --- 1. Define Options ---
  options.nm.docker.container.jenkins = {
    enable = mkEnableOption "Enable the Jenkins CI/CD server with Docker-in-Docker (Dind) support";

    # General configuration
    networkName = mkOption {
      type = types.str;
      default = "jenkins";
      description = "The name of the Docker network shared by Jenkins and Dind.";
    };

    dataRoot = mkOption {
      type = types.str;
      default = "/var/lib/jenkins/data";
      description = "The host path for Jenkins home directory persistence (/var/jenkins_home).";
    };

    certsRoot = mkOption {
      type = types.str;
      default = "/var/lib/jenkins/certs";
      description = "The host path for Docker TLS certificates.";
    };

    hostPortUI = mkOption {
      type = types.int;
      default = 1010;
      description = "The host port exposed for the Jenkins Blue Ocean web interface (maps to 8080).";
    };

    hostPortAgent = mkOption {
      type = types.int;
      default = 50000;
      description = "The host port exposed for Jenkins agent/slave communication.";
    };

    # Custom image for Jenkins with Blue Ocean and Docker CLI pre-installed
    jenkinsImage = mkOption {
      type = types.str;
      default = "myjenkins-blueocean:2.516.3-1";
      description = "The name of the custom-built Jenkins image (e.g., myjenkins-blueocean:tag).";
    };

    # Firewall rule parameters
    dockerSubnet = mkOption {
      type = types.str;
      default = "172.27.0.0/16";
      description = "The source Docker subnet for the firewall rule (e.g., 172.27.0.0/16).";
    };

    vmSubnet = mkOption {
      type = types.str;
      default = "192.168.122.0/24";
      description = "The destination VM subnet (e.g., libvirt) for the firewall rule.";
    };
  };

  /*
  make sure to build the docker image for blueocean
  Dockerfile
  ```docker
    -$   FROM jenkins/jenkins:2.516.3-jdk21
    -$
    -$   USER root
    -$
    -$   RUN apt-get update && apt-get install -y lsb-release ca-certificates curl && \
    -$       install -m 0755 -d /etc/apt/keyrings && \
    -$       curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    -$       chmod a+r /etc/apt/keyrings/docker.asc && \
    -$       echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    -$       https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
    -$       | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    -$       apt-get update && apt-get install -y docker-ce-cli && \
    -$       apt-get clean && rm -rf /var/lib/apt/lists/*
    -$
    -$   # Install Python 3 and pip
    -$   RUN apt-get update && \
    -$       apt-get install -y python3 python3-pip python3-venv && \
    -$       rm -rf /var/lib/apt/lists/*
    -$
    -$   USER jenkins
    -$
    -$   RUN jenkins-plugin-cli --plugins "blueocean docker-workflow json-path-api"
  ```

  Then Build the Image with: `docker build -t myjenkins-blueocean:2.516.3-1 .`
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # 2.1 Container Definitions (Two containers: Dind and Jenkins App)
    virtualisation.oci-containers = {
      backend = "docker";

      containers = {
        # --- 1. Docker-in-Docker (dind) service ---
        jenkins-docker = {
          image = "docker:dind";

          # Dind uses port 2376 internally for TLS communication
          ports = ["2376"];

          volumes = [
            # TLS client certs mounted read/write for Dind to generate them
            "${cfg.certsRoot}:/certs/client"
            # Optional: Shared data volume for persistence (though Dind usually uses its internal storage)
            "${cfg.dataRoot}:/var/jenkins_home"
          ];

          environment = {
            TZ = "Asia/Dhaka";
            DOCKER_TLS_CERTDIR = "/certs";
          };

          extraOptions = [
            "--privileged"
            # Alias allows the Jenkins container to connect to "docker:2376"
            "--network-alias=docker"
          ];

          networks = [cfg.networkName];

          # Use overlay2 storage driver inside dind
          cmd = ["--storage-driver" "overlay2"];

          workdir = cfg.certsRoot; # Use certs root as workdir for easy cert generation access
          autoStart = true;
        };

        # --- 2. Jenkins with Blue Ocean + Docker CLI support ---
        jenkins-blueocean = {
          image = cfg.jenkinsImage;

          volumes = [
            # Jenkins home persistence
            "${cfg.dataRoot}:/var/jenkins_home"
            # Read-only mount of the generated TLS client certs
            "${cfg.certsRoot}:/certs/client:ro"
          ];

          ports = [
            "${toString cfg.hostPortUI}:8080"
            "${toString cfg.hostPortAgent}:50000"
          ];

          environment = {
            TZ = "Asia/Dhaka";
            # Tells Jenkins where to find the Docker daemon (Dind container via network alias)
            DOCKER_HOST = "tcp://docker:2376";
            DOCKER_CERT_PATH = "/certs/client";
            DOCKER_TLS_VERIFY = "1";
          };

          networks = [cfg.networkName];

          workdir = "/var/jenkins_home";

          # Ensure Dind starts before Jenkins tries to connect to it
          dependsOn = ["jenkins-docker"];

          autoStart = true;
        };
      };
    };

    # 2.2 Custom Firewall Rule
    # Allow SSH access from the Docker subnet (where Jenkins pipelines run)
    # to the VM subnet (libvirt, 192.168.122.0/24)
    networking.firewall.extraCommands = ''
      # Note: This is executed as root, so paths to binaries like 'iptables' are found.
      iptables -I FORWARD -s ${cfg.dockerSubnet} -d ${cfg.vmSubnet} -p tcp --dport 22 -j ACCEPT
    '';
  };
}
