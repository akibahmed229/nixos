# Comprehensive Guide: Docker, NGINX, and Production Node.js Deployment

This document provides a detailed, two-part guide: first, on setting up a basic **NGINX** web server using **Docker** for serving static files, and second, on deploying a production-ready **Node.js** application using NGINX as a **reverse proxy** with **SSL** security.

---

## Part 1: Setting Up NGINX to Serve Static Files

This section focuses on containerization, basic package management, and NGINX configuration to serve a simple HTML and CSS website.

### 1\. Docker Environment Setup

**Docker** is a platform used to develop, ship, and run applications in isolated environments called **containers**. We'll use an **Ubuntu** container as our lightweight server environment.

#### Pulling and Running the Container

We use the `docker run` command to create and start the container, mapping a port on your host machine to the container's internal web server port.

| Command                            | Purpose                                                                                                                                     |
| :--------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------ |
| `docker pull ubuntu`               | Fetches the latest **Ubuntu OS image** from **Docker Hub**, the default public registry.                                                    |
| `docker run -it -p 9090:80 ubuntu` | **Runs a new container** from the `ubuntu` image.                                                                                           |
| **`-it`**                          | Allocates an interactive terminal (i) and keeps STDIN open (t), allowing you to interact with the container's shell.                        |
| **`-p 9090:80`**                   | **Port mapping**: Forwards traffic from the host machine's port **9090** to the container's internal port **80** (where NGINX will listen). |

<br>

### 2\. Installing Packages and Starting NGINX

Once inside the container's shell, we install the necessary tools.

#### Installation Commands

```sh
# Update package lists and upgrade installed packages
apt update && apt upgrade

# Install NGINX (the web server) and Neovim (a powerful text editor)
apt install nginx neovim
```

#### Verifying and Starting the Web Server

| Command    | Purpose                                                                                                                          |
| :--------- | :------------------------------------------------------------------------------------------------------------------------------- |
| `nginx -v` | **Verification**: Confirms NGINX installed correctly and displays the version.                                                   |
| `nginx`    | **Execution**: Starts the NGINX web server process. By default, it listens for HTTP traffic on **port 80** within the container. |

> ⚠️ **Common Mistake: Missing the `-it` flag**
> If you omit the `-it` when running the container, the container will immediately exit because it has no foreground process to run. **Solution**: Use `docker run -it ...` or use `docker start [container_id]` and `docker attach [container_id]` if it's already created.

<br>

### 3\. NGINX Configuration for Static Files

The primary NGINX configuration file is located at `/etc/nginx/nginx.conf`. We will modify this file to serve our website's static content.

#### Configuration Workflow

1.  **Navigate**: `cd /etc/nginx`
2.  **Backup**: `mv nginx.conf nginx.backup` (Preserves the default configuration)
3.  **Create/Edit**: `nvim nginx.conf`
4.  **Reload**: `nginx -s reload` (Applies the new configuration without stopping the server)

#### Creating the Static Content

We must create the website files _before_ referencing them in the NGINX configuration.

```sh
# Create a root directory for the website inside /etc/nginx
mkdir MyWebSite

# Create the essential files
touch MyWebSite/index.html
touch MyWebSite/style.css
```

#### Sample Website Files

**`MyWebSite/index.html`**

```html
<html>
  <head>
    <title>Ahmed X Nginx</title>
    <link rel="stylesheet" href="style.css" />
  </head>
  <body>
    <h1>Hello From NGINX</h1>
    <p>This is a simple NGINX WebPage</p>
  </body>
</html>
```

**`MyWebSite/style.css`**

```css
body {
  background-color: black;
  color: white;
}
```

#### Final NGINX Static File Configuration (`nginx.conf`)

This configuration tells NGINX **where to find** the files and how to handle file types.

```nginx
events {
    # The events block handles how NGINX manages connections (e.g., number of worker processes).
}

http {
    # The http block contains server configurations.

    # 🔑 MIME Types: Defines file extensions and their corresponding content types (crucial for browsers)
    types {
        text/css css;
        text/html html;
    }

    server {
        # The server block defines a virtual host.
        listen 80;            # Listen for HTTP requests on the container's port 80.
        server_name _;        # Wildcard: Matches requests for any domain name.

        # 🎯 Root Directive: Defines the base directory for file lookups.
        root /etc/nginx/MyWebSite;

        # When a request comes in (e.g., http://host:9090/), NGINX will look for
        # index.html inside the directory defined by the 'root' directive.
    }
}
```

> **Testing**: After reloading NGINX (`nginx -s reload`), you should be able to access the website by pointing your host machine's browser to **`http://localhost:9090`**.

---

## Part 2: Production Deployment of a Node.js Application

This section details using NGINX as a **reverse proxy** to deploy a Node.js application, including process management, firewall setup, and SSL encryption.

### 4\. Application and Infrastructure Setup

In a production environment, we deploy the Node.js application on a high, non-standard port (e.g., **5173**) and use NGINX to handle the public-facing traffic on the standard port (80/443).

#### Installing Required Tools

The installation command includes all necessary components for a robust deployment.

```sh
apt install git nvim nginx tmux nodejs ufw python3-certbot-nginx
```

| Tool                        | Purpose                                                                                      |
| :-------------------------- | :------------------------------------------------------------------------------------------- |
| **`nodejs`**                | The runtime environment for the application.                                                 |
| **`git`**                   | For cloning the project source code.                                                         |
| **`tmux`**                  | A terminal multiplexer for managing multiple sessions (useful for running background tasks). |
| **`ufw`**                   | The Uncomplicated Firewall, used to secure the server.                                       |
| **`python3-certbot-nginx`** | The tool for obtaining and configuring **SSL/TLS certificates** from Let's Encrypt.          |

#### Cloning and Installing the Project

```sh
# Clone the repository containing the Node.js project
git clone https://github.com/akibahmed229/Java-Employee_Management-System-Website.git

# Navigate into the project folder
cd Java-Employee_Management-System-Website

# Install dependencies defined in package.json
npm install
```

#### Process Management and Firewall

We use **PM2** (Process Manager 2) to ensure the Node.js application runs continuously and automatically restarts if it crashes.

1.  **Install PM2 globally**:
    ```sh
    sudo npm i pm2 -g
    ```
2.  **Start the application**:
    ```sh
    pm2 start index.js --name "myapp"
    # Note: Using 'index.js' is more explicit than 'index'
    ```
3.  **Enable Firewall**:

    ```sh
    # Enables the firewall (WARNING: This will block all unapproved traffic)
    ufw enable

    # Explicitly allow inbound HTTP traffic on standard web port 80
    sudo ufw allow 'Nginx HTTP' # Or sudo ufw allow 80
    ```

<br>

### 5\. Configuring NGINX as a Reverse Proxy

A **reverse proxy** sits in front of the application server, accepting client requests and forwarding them to the application. This setup centralizes security (SSL), load balancing, and static file serving, leaving the Node.js app to focus purely on business logic.

#### Reverse Proxy Configuration (`/etc/nginx/nginx.conf`)

```nginx
events { }

http {
    server {
        # Listen for connections on standard HTTP port 80 (IPv4 and IPv6)
        listen 80 default_server;
        listen [::]:80 default_server;

        server_name yourdomain.com www.yourdomain.com; # IMPORTANT: Replace with your actual domain

        location / {
            # 🎯 The core reverse proxy directive: Forward requests to the Node.js app running locally on port 5173
            proxy_pass http://localhost:5173;

            # 🤝 Essential Proxy Headers for correct communication
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade; # Required for WebSockets
            proxy_set_header Connection 'upgrade';  # Required for WebSockets
            proxy_set_header Host $host;            # Passes the original domain name to the backend app
            proxy_cache_bypass $http_upgrade;       # Ensures WebSocket requests bypass any proxy cache
        }

        # NOTE: The original 'root /var/www/html;' and 'index ...' directives are typically
        # removed or placed in a separate location block when using a reverse proxy for the root location.
    }
}
```

> **QOL Enhancement: Using Multiple Config Files**
> In production, it's better practice to create a dedicated configuration file for your site in `/etc/nginx/sites-available/yourdomain.conf` and create a symbolic link to `/etc/nginx/sites-enabled/`. This avoids cluttering the main `nginx.conf` and makes managing multiple sites easier.

<br>

### 6\. Securing with SSL/TLS (HTTPS)

**SSL/TLS** (Secure Sockets Layer/Transport Layer Security) encrypts communication between the user's browser and the server, creating **HTTPS**. We use **Certbot** with the **Let's Encrypt** service to automate this process.

#### Installing the Certificate

The `certbot` command automatically edits the NGINX configuration to redirect HTTP (port 80) traffic to HTTPS (port 443) and adds the necessary certificate files.

```sh
# This command automatically obtains a certificate for your domain and configures NGINX
certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

#### Testing Automated Renewal

Let's Encrypt certificates are only valid for 90 days, so automated renewal is essential.

```sh
# Performs a dry run to test the renewal process without actually renewing
certbot renew --dry-run
```

> **Best Practice: Port Management**
> After enabling SSL, confirm your firewall (`ufw`) is allowing **HTTPS traffic** on port **443**: `sudo ufw allow 'Nginx Full'`.

---

## Advanced Techniques: Optimizing a Dockerized NGINX/Node.js Stack

This section explores advanced concepts for performance, security, and maintainability in your deployed environment.

### 7\. Performance and Hardening with NGINX

#### A. Caching Static Assets

NGINX can significantly improve page load times by caching static files like images, CSS, and JavaScript.

**Advanced Configuration Snippet:**

```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    # Match common static file extensions
    expires 30d; # Tell the client's browser to cache these files for 30 days
    add_header Pragma "public";
    add_header Cache-Control "public, must-revalidate, proxy-revalidate";

    # Ensure NGINX serves these files directly (important when using a root directive)
    root /path/to/static/assets;

    # ⚠️ Use a separate location block for caching, not the main proxy_pass block
}
```

#### B. Rate Limiting for Security

Rate limiting prevents abuse and Denial of Service (DoS) attacks by restricting the number of requests a single client can make over a period of time.

```nginx
# 1. Define the limit zone in the http block
# 'mylimit' is the zone name, 1m is the size (1MB), and 5r/s is 5 requests per second
limit_req_zone $binary_remote_addr zone=mylimit:1m rate=5r/s;

server {
    # 2. Apply the limit in the server or location block
    location /login/ {
        # Burst allows a short burst of requests above the limit before throttling.
        limit_req zone=mylimit burst=10 nodelay;
        proxy_pass http://localhost:5173;
    }
}
```

### 8\. Docker Best Practices and Automation

#### A. Using Multi-Stage Builds

When creating a production **Docker image** for a Node.js application, using a **multi-stage build** dramatically reduces the final image size by discarding build-time dependencies.

**Conceptual Dockerfile Snippet:**

```dockerfile
# Stage 1: Build Stage (Uses a heavy image for building)
FROM node:20-slim as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build # Assuming a build script exists

# Stage 2: Production Stage (Uses a tiny image for running)
FROM node:20-slim
WORKDIR /app
# Only copy the essential files from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/index.js ./ # Or whatever your entry file is
CMD [ "pm2-runtime", "start", "index.js" ]
```

#### B. PM2 Ecosystem File

Instead of managing startup via the command line, use a **PM2 Ecosystem file** (`ecosystem.config.js`) to standardize configuration, logging, and environment variables.

**Example:**

```javascript
module.exports = {
  apps: [
    {
      name: "node-app-prod",
      script: "./index.js",
      instances: "max", // Run on all available CPU cores
      exec_mode: "cluster",
      env: {
        NODE_ENV: "production",
        PORT: 5173,
      },
    },
  ],
};
```

**Start command:** `pm2 start ecosystem.config.js`

### 9\. Troubleshooting and Diagnostics

#### A. Checking NGINX Configuration Errors

Before reloading NGINX, always check the configuration syntax to prevent downtime.

```sh
nginx -t
# Output should be: "syntax is ok" and "test is successful"
```

#### B. Diagnosing PM2/Node.js Issues

If your application isn't responding through NGINX, check the logs and status of your PM2 process.

| Command          | Purpose                                                                |
| :--------------- | :--------------------------------------------------------------------- |
| `pm2 status`     | Shows the current running status, uptime, and process ID.              |
| `pm2 logs myapp` | Streams the application's standard output and error logs in real-time. |
| `pm2 monit`      | Opens a real-time terminal dashboard to monitor CPU, Memory, and logs. |

---
