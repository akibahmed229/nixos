## Docker and NGINX Setup Guide

### Pull and Run an Ubuntu Docker Container
```sh
# Pull the latest Ubuntu image from Docker Hub
docker pull ubuntu

# Run a container from the Ubuntu image, mapping port 80 of the container to port 9090 of the host
docker run -it -p 9090:80 ubuntu
```

### Inside the Ubuntu Container
```sh
# Update package lists and upgrade installed packages
apt update && apt upgrade

# Install NGINX and Neovim
apt install nginx neovim

# Verify NGINX installation
nginx -v

# Start NGINX (default port is 80)
nginx
```

### NGINX Configuration Workaround
```sh
# Navigate to the NGINX configuration directory
cd /etc/nginx

# Backup the existing nginx.conf file
mv nginx.conf nginx.backup

# Create a new nginx.conf file using Neovim
nvim nginx.conf

# Reload NGINX with the new configuration
nginx -s reload
```

### Basic NGINX Configuration (`nginx.conf`)
```nginx
events {
    # Events block (required but can be empty)
}

http {
    # HTTP block to define server and location settings

    server {
        # Server block to handle incoming connections
        listen 80;  # Listen on port 80
        server_name _;  # Handle requests for any server name

        location / {
            # Location block to match the root URL
            return 200 "Hello, World from NGINX";
        }
    }
}
```

### Serving Static Files
```sh
# Create a directory for your website
mkdir MyWebSite

# Create an HTML file for the website
touch MyWebSite/index.html

# Create a CSS file for the website
touch MyWebSite/style.css
```

### Sample HTML File (`index.html`)
```html
<html>
    <head>
        <title>Ahmed X Nginx</title>
        <link rel="stylesheet" href="style.css"/>
    </head>
    <body>
        <h1>Hello From NGINX</h1>
        <p>This is a simple NGINX WebPage</p>
    </body>
</html>
```

### Sample CSS File (`style.css`)
```css
body {
    background-color: black;
    color: white;
}
```

### Updated NGINX Configuration for Serving Static Files (`nginx.conf`)
```nginx
events {
    # Events block (required but can be empty)
}

http {
    # HTTP block to define server and location settings

    # Define MIME types directly (or include from an external file)
    # include /etc/nginx/mime.types;
    types {
        text/css css;
        text/html html;
    }

    server {
        # Server block to handle incoming connections
        listen 80;  # Listen on port 80
        server_name _;  # Handle requests for any server name

        # Define the root directory for static files
        root /etc/nginx/MyWebSite;
    }
}
```
This guide walks you through setting up a Docker container with Ubuntu, installing and configuring NGINX, and serving static files with a basic website. The comments should help you understand each step and the purpose of each command and configuration block.

## Full Node.js Deployment Using Docker

### Install Necessary Packages
```sh
# Install essential packages including Git, Neovim, NGINX, tmux, Node.js, UFW, and Certbot
apt install git nvim nginx tmux nodejs ufw python3-certbot-nginx
```

### Download Your Project
```sh
# Clone the project repository from GitHub
git clone https://github.com/akibahmed229/Java-Employee_Management-System-Website.git

# Change directory to the project folder
cd Java-Employee_Management-System-Website

# Install project dependencies using npm
npm install
```

### Setup and Start the Node.js Application
```sh
# Install pm2 globally to manage Node.js processes
sudo npm i pm2 -g

# Start the application using pm2
pm2 start index

# Enable the UFW firewall
ufw enable 

# Allow HTTP traffic on port 80 through the firewall
sudo ufw allow http 80
```

### Configure NGINX as a Reverse Proxy
1. **Edit the NGINX configuration file**:
    ```sh
    # Open the NGINX configuration file using Neovim
    nvim /etc/nginx/nginx.conf
    ```

2. **Ensure the configuration file looks like this**:
    ```nginx
    events {
        # Events block (required but can be empty)
    }

    http {
        # HTTP block to define server and location settings

        server {
            # Server block to handle incoming connections

            listen 80 default_server;  # Listen on port 80 (IPv4)
            listen [::]:80 default_server;  # Listen on port 80 (IPv6)
            root /var/www/html;  # Define the root directory for static files
            index index.html index.htm index.nginx-debian.html;  # Default index files

            server_name localhost;  # Server name (adjust if using a domain)

            location / {
                # Location block to match the root URL

                proxy_pass http://localhost:5173;  # Proxy requests to the Node.js app
                proxy_http_version 1.1;  # Use HTTP/1.1 for proxying
                proxy_set_header Upgrade $http_upgrade;  # Handle WebSocket upgrades
                proxy_set_header Connection 'upgrade';  # Handle WebSocket upgrades
                proxy_set_header Host $host;  # Preserve the original Host header
                proxy_cache_bypass $http_upgrade;  # Bypass cache for WebSocket upgrades
            }
        }
    }
    ```

### Setup SSL with Certbot
```sh
# Obtain and install an SSL certificate for your domain using Certbot
certbot --nginx -d yourdomain.com

# Test the certificate renewal process (certificates are only valid for 90 days)
certbot renew --dry-run
```

### Summary
1. **Install necessary packages**: Git, Neovim, NGINX, tmux, Node.js, UFW, Certbot.
2. **Clone the project**: Use Git to download your Node.js project.
3. **Install dependencies**: Use npm to install project dependencies.
4. **Setup pm2**: Manage your Node.js application with pm2.
5. **Configure firewall**: Enable UFW and allow HTTP traffic.
6. **Configure NGINX**: Set up NGINX as a reverse proxy to forward requests to your Node.js application.
7. **Setup SSL**: Use Certbot to secure your application with SSL.

By following these steps, you'll have a fully deployed Node.js application using Docker, NGINX, and SSL for secure communication.