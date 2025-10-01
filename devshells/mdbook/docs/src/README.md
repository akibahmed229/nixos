# 📂 Docs File Structure Guide

This project uses **Nix + mdBook** to automatically build documentation.
The `flake.nix` is configured to **scan directories recursively** and generate a proper `SUMMARY.md` (the sidebar navigation).

---

## 🏗 How the Structure Works

- Each **folder** becomes a **section** in the sidebar.
- Each `readme.md` inside a folder becomes a **clickable page** for that section.
- Subfolders create **nested sections** automatically.
- `README.md` in the root is treated as the **home/landing page**.

---

## 📌 Example File Tree

```bash
docs
├── book.toml         # mdBook config file
└── src               # All content lives here
    ├── README.md     # Landing page (home)
    ├── DataBase
    │   └── Relational
    │       ├── MySQL
    │       │   └── readme.md
    │       └── readme.md
    ├── Deployment
    │   └── Web_App
    │       ├── MERN_App
    │       │   └── readme.md
    │       └── readme.md
    ├── Linux
    │   ├── Distubation
    │   │   ├── NixOS
    │   │   │   └── readme.md
    │   │   └── readme.md
    │   ├── Installation
    │   │   ├── Arch
    │   │   │   └── readme.md
    │   │   ├── Gentoo
    │   │   │   └── readme.md
    │   │   └── readme.md
    │   └── Tools
    │       ├── Bash
    │       │   └── readme.md
    │       ├── Git
    │       │   └── readme.md
    │       └── readme.md
    └── Networking
        ├── Basic
        │   ├── Common_Ports
        │   │   └── readme.md
        │   ├── IPv4_Subnetting
        │   │   └── readme.md
        │   └── readme.md
        └── Tools
            ├── Curl
            │   └── readme.md
            ├── Nmap
            │   └── readme.md
            └── readme.md
```

---

## 📖 Example Sidebar (Generated)

This structure will automatically produce a sidebar like:

```
Home
DataBase
  Relational
    MySQL
Deployment
  Web_App
    MERN_App
Linux
  Distubation
    NixOS
  Installation
    Arch
    Gentoo
  Tools
    Bash
    Git
Networking
  Basic
    Common_Ports
    IPv4_Subnetting
  Tools
    Curl
    Nmap
```

## Example SUMMARY.md Output

```md
# Summary

- [Home](./README.md)

# DataBase

- [Relational](./DataBase/Relational/readme.md)
  - [MySQL](./DataBase/Relational/MySQL/readme.md)

# Deployment

- [Web_App](./Deployment/Web_App/readme.md)
  - [MERN_App](./Deployment/Web_App/MERN_App/readme.md)

# Linux

- [Distubation](./Linux/Distubation/readme.md)
  - [NixOS](./Linux/Distubation/NixOS/readme.md)
- [Installation](./Linux/Installation/readme.md)
  - [Arch](./Linux/Installation/Arch/readme.md)
  - [Gentoo](./Linux/Installation/Gentoo/readme.md)
- [Tools](./Linux/Tools/readme.md)
  - [Bash](./Linux/Tools/Bash/readme.md)
  - [Git](./Linux/Tools/Git/readme.md)
  - [NFS_Server](./Linux/Tools/NFS_Server/readme.md)
  - [Nginx](./Linux/Tools/Nginx/readme.md)
  - [OpenSSH](./Linux/Tools/OpenSSH/readme.md)
  - [PostfixMail](./Linux/Tools/PostfixMail/readme.md)
  - [SysMonitor](./Linux/Tools/SysMonitor/readme.md)

# Networking

- [Basic](./Networking/Basic/readme.md)
  - [Common_Ports](./Networking/Basic/Common_Ports/readme.md)
  - [IPv4_Subnetting](./Networking/Basic/IPv4_Subnetting/readme.md)
- [Tools](./Networking/Tools/readme.md)
  - [Curl](./Networking/Tools/Curl/readme.md)
  - [Nmap](./Networking/Tools/Nmap/readme.md)
  - [SSH](./Networking/Tools/SSH/readme.md)
  - [Wireshark](./Networking/Tools/Wireshark/readme.md)
```

---

## 🚀 How to Add New Content

1. Create a folder under `docs/src/`.

   ```bash
   mkdir -p docs/src/DevOps/Docker
   ```

2. Add a `readme.md` inside it:

   ```bash
   echo "# Docker Notes" > docs/src/DevOps/Docker/readme.md
   ```

3. Rebuild:

   ```bash
   nix build .#my-project-docs
   ```

4. mdBook will automatically regenerate the sidebar and include your new section. 🎉

---

⚡ **Pro Tip**:

- Always name content files `readme.md` (not `README.md` inside subfolders).
- Use `README.md` **only at the root** for the homepage.

---

Today's date is: <!-- cmdrun date -->
