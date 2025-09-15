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
          DOCKER_TLS_CERTDIR = "/certs";
        };

        extraOptions = [
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
          -$  FROM jenkins/jenkins:2.516.2-jdk21
          -$  USER root
          -$  RUN apt-get update && apt-get install -y lsb-release
          -$  RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
          -$      https://download.docker.com/linux/debian/gpg
          -$  RUN echo "deb [arch=$(dpkg --print-architecture) \
          -$      signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
          -$      https://download.docker.com/linux/debian \
          -$      $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
          -$  RUN apt-get update && apt-get install -y docker-ce-cli
          -$  USER jenkins
          -$  RUN jenkins-plugin-cli --plugins "blueocean docker-workflow json-path-api"
      ```

      then run: `docker build -t myjenkins-blueocean:2.516.2-1 .`
      */

      # Jenkins with Blue Ocean + Docker CLI support
      jenkins-blueocean = {
        # You need to build this custom image yourself before using
        # docker build -t myjenkins-blueocean:2.516.2-1 .
        image = "myjenkins-blueocean:2.516.2-1";

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
}
