# SSH Cheat Sheet

Whether you need a quick recap of SSH commands or you’re learning SSH from scratch, this guide will help. SSH is a must-have tool for network administrators and anyone who needs to log in to remote systems securely.

---

## 🔑 What Is SSH?

**SSH (Secure Shell / Secure Socket Shell)** is a network protocol that allows secure access to network services over unsecured networks.

Key tools included in the suite:

- **ssh-keygen** → Create SSH authentication key pairs.
- **scp (Secure Copy Protocol)** → Copy files securely between hosts.
- **sftp (Secure File Transfer Protocol)** → Securely send/receive files.

By default, an SSH server listens on **TCP port 22**.

---

## 📝 Basic SSH Commands

| Command                                                    | Description                        |
| ---------------------------------------------------------- | ---------------------------------- |
| `ssh user@host`                                            | Connect to remote server           |
| `ssh pi@raspberry`                                         | Connect as `pi` on default port 22 |
| `ssh pi@raspberry -p 3344`                                 | Connect on custom port 3344        |
| `ssh -i /path/file.pem admin@192.168.1.1`                  | Connect using private key file     |
| `ssh root@192.168.2.2 'ls -l'`                             | Execute remote command             |
| `ssh user@192.168.3.3 bash < script.sh`                    | Run script remotely                |
| `ssh friend@Best.local "tar cvzf - ~/ffmpeg" > output.tgz` | Download compressed directory      |

### 🔐 Key Management

| Command                                            | Description                      |
| -------------------------------------------------- | -------------------------------- |
| `ssh-keygen`                                       | Generate SSH keys                |
| `ssh-keygen -F [host]`                             | Find entry in `known_hosts`      |
| `ssh-keygen -R [host]`                             | Remove entry from `known_hosts`  |
| `ssh-keygen -y -f private.key > public.pub`        | Generate public key from private |
| `ssh-keygen -t rsa -b 4096 -C "email@example.com"` | Generate new RSA 4096-bit key    |

---

## 📂 File Transfers

### **SCP (Secure Copy)**

| Command                                       | Description                |
| --------------------------------------------- | -------------------------- |
| `scp user@server:/file dest/`                 | Copy remote → local        |
| `scp file user@server:/path`                  | Copy local → remote        |
| `scp user1@server1:/file user2@server2:/path` | Copy between two servers   |
| `scp -r user@server:/folder dest/`            | Copy directory recursively |
| `scp -P 8080 file user@server:/path`          | Connect on port 8080       |
| `scp -C`                                      | Enable compression         |
| `scp -v`                                      | Verbose output             |

### **SFTP (Secure File Transfer)**

| Command                         | Description                    |
| ------------------------------- | ------------------------------ |
| `sftp user@server`              | Connect to server via SFTP     |
| `sftp -P 8080 user@server`      | Connect on port 8080           |
| `sftp -r dir user@server:/path` | Recursively transfer directory |

---

## ⚙️ SSH Configurations & Options

| Command                    | Description                            |
| -------------------------- | -------------------------------------- |
| `man ssh_config`           | SSH client configuration manual        |
| `cat /etc/ssh/ssh_config`  | View system-wide SSH client config     |
| `cat /etc/ssh/sshd_config` | View system-wide SSH **server** config |
| `cat ~/.ssh/config`        | View user-specific config              |
| `cat ~/.ssh/known_hosts`   | View logged-in hosts                   |

### **SSH Agent & Keys**

| Command                   | Description                      |
| ------------------------- | -------------------------------- |
| `ssh-agent`               | Start agent to hold private keys |
| `ssh-add ~/.ssh/id_rsa`   | Add key to agent                 |
| `ssh-add -l`              | List cached keys                 |
| `ssh-add -D`              | Delete all cached keys           |
| `ssh-copy-id user@server` | Copy keys to remote server       |

---

## 🖥️ Remote Server Management

After logging into a remote server:

- `cd` → Change directory
- `ls` → List files
- `mkdir` → Create directory
- `mv` → Move/rename files
- `nano/vim` → Edit files
- `ps` → List processes
- `kill` → Stop process
- `top` → Monitor resources
- `exit` → Close SSH session

---

## 🚀 Advanced SSH Commands

### X11 Forwarding (GUI Apps over SSH)

- Client `~/.ssh/config`:

  ```
  Host *
    ForwardAgent yes
    ForwardX11 yes
  ```

- Server `/etc/ssh/sshd_config`:

  ```
  X11Forwarding yes
  X11DisplayOffset 10
  X11UseLocalhost no
  ```

| Command                                | Description                     |
| -------------------------------------- | ------------------------------- |
| `sshfs user@server:/path /local/mount` | Mount remote filesystem locally |
| `ssh -C user@host`                     | Enable compression              |
| `ssh -X user@server`                   | Enable X11 forwarding           |
| `ssh -Y user@server`                   | Enable trusted X11 forwarding   |

---

## 🔒 SSH Tunneling

### Local Port Forwarding `-L`

```
ssh -L local_port:destination:remote_port user@server
```

Example: `ssh -L 2222:10.0.1.5:3333 root@192.168.0.1`

### Remote Port Forwarding `-R`

```
ssh -R remote_port:destination:destination_port user@server
```

Example: `ssh -R 8080:192.168.3.8:3030 -N -f user@remote.host`

### Dynamic Port Forwarding `-D` (SOCKS Proxy)

```
ssh -D 6677 -q -C -N -f user@host
```

### ProxyJump `-J` (Bastion Host)

```
ssh -J user@proxy_host user@target_host
```

---

## 🛡️ Security Best Practices

- Disable unused features: `AllowTcpForwarding no`, `X11Forwarding no`.
- Change default port from `22` to something else.
- Use **SSH certificates** with `ssh-keygen`.
- Restrict logins with `AllowUsers` in `sshd_config`.
- Use bastion hosts for added security.

---

## ✅ Conclusion

This cheat sheet covered:

- Basic SSH connections
- File transfers (SCP/SFTP)
- Key management & configs
- Remote management commands
- Advanced tunneling & forwarding

SSH remains an indispensable tool for IT professionals and security practitioners.
