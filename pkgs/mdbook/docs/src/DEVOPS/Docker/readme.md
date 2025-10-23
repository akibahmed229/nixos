### Core Concepts

- **Image:** A lightweight, standalone, executable package. It's a blueprint that includes everything needed to run an application: code, runtime, system tools, and libraries.
- **Container:** A running instance of an image. It's the actual, isolated environment where your application runs. You can create, start, stop, and delete multiple containers from a single image.
- **Docker Hub:** A public registry (like GitHub for code) where you can find, share, and store container images.
- **Dockerfile:** A text file with instructions for building a Docker image.

---

### Image Management (Build, Pull, List)

Commands for building, downloading, and managing your local images.

| Command                        | Description                                                                                                                                                         |
| :----------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `docker build -t <name:tag> .` | **Build an image** from a `Dockerfile` in the current directory (`.`). The `-t` flag **tags** it with a human-readable `name` and `tag` (e.g., `-t my-app:latest`). |
| `docker build --no-cache ...`  | **Build an image without using the cache.** Use this to force a fresh build from scratch.                                                                           |
| `docker pull <image_name>`     | **Download (pull) an image** from a registry like Docker Hub (e.g., `docker pull postgres`).                                                                        |
| `docker images`                | **List all images** stored locally on your machine.                                                                                                                 |
| `docker rmi <image_name>`      | **Remove (delete) a local image.** You may need to stop/remove containers using it first.                                                                           |
| `docker search <term>`         | **Search Docker Hub** for images matching a search term.                                                                                                            |

---

### Container Lifecycle (Run, Stop, Interact)

Commands for creating, running, and managing your containers.

| Command                                              | Description                                                                                                                |
| :--------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------- |
| `docker run <image_name>`                            | **Create and start a new container** from an image.                                                                        |
| `docker run -d <image_name>`                         | **Run in detached mode** (in the background). The terminal will be freed up.                                               |
| `docker run --name <my-name> ...`                    | **Give your container a custom name** (e.g., `my-db-container`).                                                           |
| `docker run -p 8080:80 ...`                          | **Map a port** from your local machine (host) to the container. This example maps host port `8080` to container port `80`. |
| `docker run -v /path/on/host:/path/in/container ...` | **Mount a volume** to persist data. This links a host directory to a container directory.                                  |
| `docker run --rm ...`                                | **Automatically remove the container** when it stops. Excellent for temporary tasks and cleanup.                           |
| `docker run -it <image_name> sh`                     | **Run in interactive mode** (`-it`). This opens a shell (`sh` or `bash`) inside the new container.                         |
| `docker exec -it <container_name> sh`                | **Execute a command** (like `sh`) inside an _already running_ container.                                                   |
| `docker start <container_name>`                      | **Start a stopped container.**                                                                                             |
| `docker stop <container_name>`                       | **Stop a running container** gracefully.                                                                                   |
| `docker kill <container_name>`                       | **Force-stop a running container** immediately.                                                                            |
| `docker rm <container_name>`                         | **Remove a stopped container.**                                                                                            |
| `docker rm -f <container_name>`                      | **Force-remove** a container (even if it's running).                                                                       |

---

### Inspection & Logs

Commands for checking the status, logs, and details of your containers.

| Command                           | Description                                                                                                   |
| :-------------------------------- | :------------------------------------------------------------------------------------------------------------ |
| `docker ps`                       | **List all _running_ containers.**                                                                            |
| `docker ps -a`                    | **List _all_ containers** (running and stopped).                                                              |
| `docker logs <container_name>`    | **Show the logs** (console output) of a container.                                                            |
| `docker logs -f <container_name>` | **Follow the logs** in real-time (streams the live output).                                                   |
| `docker inspect <container_name>` | **Show detailed information (JSON)** about a container, including its IP address, port mappings, and volumes. |
| `docker container stats`          | **Show a live stream** of resource usage (CPU, Memory, Network) for all running containers.                   |

---

### Docker Hub & Registries

Commands for authenticating and sharing your custom images.

| Command                               | Description                                                                                                                                    |
| :------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------- |
| `docker login`                        | **Log in** to Docker Hub or another container registry. You'll be prompted for your credentials.                                               |
| `docker push <username>/<image_name>` | **Push (upload) your local image** to Docker Hub. The image must be tagged with your username first (e.g., `docker build -t myuser/my-app .`). |

---

### System Cleanup (QOL)

Essential commands for freeing up disk space.

| Command                            | Description                                                                                                                             |
| :--------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------- |
| `docker container prune`           | **Remove all stopped containers.**                                                                                                      |
| `docker image prune`               | **Remove dangling images** (images that aren't tagged or used by any container).                                                        |
| `docker image prune -a`            | **Remove all unused images** (any image not used by at least one container).                                                            |
| `docker volume prune`              | **Remove all unused volumes** (volumes not attached to any container).                                                                  |
| `docker system prune`              | **The "big one":** Removes all stopped containers, all dangling images, and all unused networks.                                        |
| `docker system prune -a --volumes` | **The "nuke":** Removes all stopped containers, _all unused images_ (not just dangling), all unused networks, and _all unused volumes_. |

---

### Docker Compose (Advanced)

The standard tool for defining and running **multi-container** applications (e.g., a web app, a database, and a cache). It uses a `docker-compose.yml` file.

| Command                                 | Description                                                                                                 |
| :-------------------------------------- | :---------------------------------------------------------------------------------------------------------- |
| `docker compose up`                     | **Build and start all services** defined in your `docker-compose.yml` file. Runs in the foreground.         |
| `docker compose up -d`                  | **Build and start all services in detached mode** (in the background).                                      |
| `docker compose down`                   | **Stop and remove all containers,** networks, and (by default) default volumes defined in the compose file. |
| `docker compose down -v`                | **Stop and remove everything, _including named volumes_.**                                                  |
| `docker compose ps`                     | **List all containers** managed by the current compose project.                                             |
| `docker compose logs`                   | **Show logs from all services** in the compose project.                                                     |
| `docker compose logs -f <service_name>` | **Follow the logs** in real-time for one or more specific services.                                         |
| `docker compose exec <service_name> sh` | **Execute a command** (like `sh`) inside a running service's container.                                     |
| `docker compose build`                  | **Force a rebuild** of the images for your services before starting.                                        |

---

### Volumes & Networking (Advanced)

Commands for explicitly managing persistent data and custom networks.

| Command                                    | Description                                                                                     |
| :----------------------------------------- | :---------------------------------------------------------------------------------------------- |
| `docker volume ls`                         | **List all volumes** on your system.                                                            |
| `docker volume create <volume_name>`       | **Create a new managed volume.**                                                                |
| `docker volume inspect <volume_name>`      | **Show detailed information** about a volume.                                                   |
| `docker volume rm <volume_name>`           | **Remove one or more volumes.**                                                                 |
| `docker network ls`                        | **List all networks** on your system.                                                           |
| `docker network create <network_name>`     | **Create a new custom bridge network.** Containers on the same network can communicate by name. |
| `docker network inspect <network_name>`    | **Show detailed information** about a network.                                                  |
| `docker network connect <net> <container>` | **Connect a running container** to an additional network.                                       |
