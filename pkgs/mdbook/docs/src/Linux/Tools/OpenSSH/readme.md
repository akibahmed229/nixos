

# **Setting Up SSH Server Between PC and Server**

This guide explains how to set up and configure an SSH server to enable secure communication between a client PC and a server.

---

## **Prerequisites**
1. A Linux-based PC (client) and server.
2. SSH package installed on both machines.
3. Network connectivity between the PC and the server.

---

## **Step-by-Step Instructions**

### **Step 1: Install OpenSSH**
On both the client and server, install the OpenSSH package:

#### On the Server:
```bash
sudo apt update
sudo apt install openssh-server
````

#### On the Client:

```bash
sudo apt update
sudo apt install openssh-client
```

---

### **Step 2: Start and Enable SSH Service**

Ensure the SSH service is running on the server:

```bash
sudo systemctl start ssh
sudo systemctl enable ssh
```

Check the service status:

```bash
sudo systemctl status ssh
```

---

### **Step 3: Configure SSH on the Server**

1. Open the SSH configuration file:
    
    ```bash
    sudo nano /etc/ssh/sshd_config
    ```
    
2. Modify or verify the following settings:
    
    - **PermitRootLogin:** Set to `no` for security.
    - **PasswordAuthentication:** Set to `yes` to allow password-based logins initially (you can disable it after setting up key-based authentication).
3. Save changes and restart the SSH service:
    
    ```bash
    sudo systemctl restart ssh
    ```
    

---

### **Step 4: Determine the Server's IP Address**

Find the server's IP address to connect from the client:

```bash
ip a
```

Look for the IP address under the active network interface (e.g., `192.168.x.x`).

---

### **Step 5: Test SSH Connection from the Client**

On the client, open a terminal and connect to the server using:

```bash
ssh username@server_ip
```

Replace `username` with the server's username and `server_ip` with the actual IP address.

Example:

```bash
ssh user@192.168.1.10
```

---

### **Step 6: Set Up Key-Based Authentication 

1. On the client, generate an SSH key pair:
    
    ```bash
    ssh-keygen -t rsa -b 4096
    ```
    
2. Copy the public key to the server:
	on Linux
    ```bash
    ssh-copy-id username@server_ip
    ```
	 on Windows go to the .ssh folder
```bash
scp $env:USERPROFILE/.ssh/id_rsa.pub username@ip:~/.ssh/authorized_keys
```
1. Verify key-based login:
    
    ```bash
    ssh username@server_ip
    ```
    
4. Disable password-based logins for added security:
    
    - Edit the server's SSH configuration file:
        
        ```bash
        sudo nano /etc/ssh/sshd_config
        ```
        
    - Set `PasswordAuthentication` to `no`.
    - Restart the SSH service:
        
        ```bash
        sudo systemctl restart ssh
        ```
        

---

### **Step 7: Troubleshooting Common Issues**

- **Firewall:** Ensure SSH traffic is allowed through the firewall on the server:
    
    ```bash
    sudo ufw allow ssh
    sudo ufw enable
    ```
    
- **Connection Refused:** Check if the SSH service is running and the correct IP address is used.
    

