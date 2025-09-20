{
  /*
  # General introduction
  # Access the jenkins-blueocean web interface by visiting https://localhost:1010
  */
  virtualisation.oci-containers = {
    backend = "docker";

    # Make sure to create a docker network
    # -$ `docker network create jenkins`
    containers = {
      # Docker-in-Docker (dind) service for Jenkins
      jenkins-docker = {
        image = "docker:dind";

        ports = [
          "2376"
        ];

        # Volume mappings to persist jenkins-docker data outside the container
        volumes = [
          "/var/lib/jenkins/certs/:/certs/client"
          "/var/lib/jenkins/data/:/var/jenkins_home"
        ];

        environment = {
          TZ = "Asia/Dhaka";
          DOCKER_TLS_CERTDIR = "/certs";
        };

        extraOptions = [
          # Running jenkins in Docker currently requires privileged access to function properly. This requirement may be relaxed with newer Linux kernel versions.
          "--privileged"
          "--network-alias=docker"
        ];

        networks = ["jenkins"];

        cmd = ["--storage-driver" "overlay2"];

        workdir = "/var/lib/jenkins/";

        autoStart = true;
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

      # Jenkins with Blue Ocean + Docker CLI support
      jenkins-blueocean = {
        # You need to build this custom image yourself before using
        image = "myjenkins-blueocean:2.516.3-1";

        # Volume mappings to persist jenkins-blueocean data outside the container
        volumes = [
          "/var/lib/jenkins/data/:/var/jenkins_home"
          "/var/lib/jenkins/certs/:/certs/client:ro"
        ];

        ports = [
          "1010:8080"
          "50000"
        ];

        environment = {
          TZ = "Asia/Dhaka";
          DOCKER_HOST = "tcp://docker:2376";
          DOCKER_CERT_PATH = "/certs/client";
          DOCKER_TLS_VERIFY = "1";
        };

        networks = ["jenkins"];

        workdir = "/var/lib/jenkins/";

        # Always restart Jenkins on failure
        autoStart = true;
      };
    };
  };

  networking.firewall.extraCommands = ''
    iptables -I FORWARD -s 172.27.0.0/16 -d 192.168.122.0/24 -p tcp --dport 22 -j ACCEPT
  '';
}
