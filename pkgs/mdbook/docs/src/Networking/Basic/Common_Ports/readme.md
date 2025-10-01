# 🛠️ Common Ports & Protocols Cheat Sheet

> A quick reference for well-known TCP/UDP ports and their usage. Useful for students, professionals, and anyone studying for certifications like **CCNA, CompTIA, or Security+**.

---

## 📌 Well-Known / System Ports (0 – 1023)

| Port    | Service             | Protocol       | Description                                                   |
| ------- | ------------------- | -------------- | ------------------------------------------------------------- |
| 7       | Echo                | TCP, UDP       | Echo service                                                  |
| 19      | CHARGEN             | TCP, UDP       | Character Generator Protocol (rarely used, vulnerable)        |
| 20      | FTP-data            | TCP, SCTP      | File Transfer Protocol (data)                                 |
| 21      | FTP                 | TCP, UDP, SCTP | File Transfer Protocol (control)                              |
| 22      | SSH/SCP/SFTP        | TCP, UDP, SCTP | Secure Shell, secure logins, file transfers, port forwarding  |
| 23      | Telnet              | TCP            | Unencrypted text communication                                |
| 25      | SMTP                | TCP            | Simple Mail Transfer Protocol (email routing)                 |
| 53      | DNS                 | TCP, UDP       | Domain Name System                                            |
| 67      | DHCP/BOOTP          | UDP            | DHCP Server                                                   |
| 68      | DHCP/BOOTP          | UDP            | DHCP Client                                                   |
| 69      | TFTP                | UDP            | Trivial File Transfer Protocol                                |
| 80      | HTTP                | TCP, UDP, SCTP | Web traffic (HTTP/1.x, HTTP/2 over TCP; HTTP/3 uses QUIC/UDP) |
| 88      | Kerberos            | TCP, UDP       | Network authentication system                                 |
| 110     | POP3                | TCP            | Post Office Protocol (email retrieval)                        |
| 123     | NTP                 | UDP            | Network Time Protocol                                         |
| 135     | Microsoft RPC EPMAP | TCP, UDP       | Remote Procedure Call Endpoint Mapper                         |
| 137-139 | NetBIOS             | TCP, UDP       | NetBIOS services (name service, datagram, session)            |
| 143     | IMAP                | TCP, UDP       | Internet Message Access Protocol                              |
| 161-162 | SNMP                | UDP            | Simple Network Management Protocol (unencrypted)              |
| 179     | BGP                 | TCP            | Border Gateway Protocol                                       |
| 389     | LDAP                | TCP, UDP       | Lightweight Directory Access Protocol                         |
| 443     | HTTPS               | TCP, UDP, SCTP | Secure web traffic (SSL/TLS)                                  |
| 445     | Microsoft DS SMB    | TCP, UDP       | File sharing, Active Directory                                |
| 465     | SMTPS               | TCP            | SMTP over SSL/TLS                                             |
| 514     | Syslog              | UDP            | System log protocol                                           |
| 520     | RIP                 | UDP            | Routing Information Protocol                                  |
| 546-547 | DHCPv6              | UDP            | DHCP for IPv6 (client/server)                                 |
| 636     | LDAPS               | TCP, UDP       | LDAP over SSL                                                 |
| 993     | IMAPS               | TCP            | IMAP over SSL/TLS                                             |
| 995     | POP3S               | TCP, UDP       | POP3 over SSL/TLS                                             |

---

## 📌 Registered Ports (1024 – 49151)

| Port      | Service           | Protocol | Description                        |
| --------- | ----------------- | -------- | ---------------------------------- |
| 1025      | Microsoft RPC     | TCP      | RPC service                        |
| 1080      | SOCKS proxy       | TCP, UDP | Proxy protocol                     |
| 1194      | OpenVPN           | TCP, UDP | VPN tunneling                      |
| 1433      | MS-SQL Server     | TCP      | Microsoft SQL Server               |
| 1521      | Oracle DB         | TCP      | Oracle Database listener           |
| 1701      | L2TP              | TCP      | Layer 2 Tunneling Protocol         |
| 1720      | H.323             | TCP      | VoIP signaling                     |
| 1723      | PPTP              | TCP, UDP | VPN protocol (deprecated)          |
| 1812-1813 | RADIUS            | UDP      | Authentication, accounting         |
| 2049      | NFS               | UDP      | Network File System                |
| 2082-2083 | cPanel            | TCP, UDP | Web hosting control panel          |
| 2222      | DirectAdmin       | TCP      | Hosting control panel              |
| 2483-2484 | Oracle DB         | TCP, UDP | Insecure & SSL listener            |
| 3074      | Xbox Live         | TCP, UDP | Online gaming                      |
| 3128      | HTTP Proxy        | TCP      | Common proxy port                  |
| 3260      | iSCSI Target      | TCP, UDP | Storage protocol                   |
| 3306      | MySQL             | TCP      | Database system                    |
| 3389      | RDP               | TCP      | Windows Remote Desktop             |
| 3690      | SVN               | TCP, UDP | Apache Subversion                  |
| 3724      | World of Warcraft | TCP, UDP | Gaming                             |
| 4333      | mSQL              | TCP      | Mini SQL                           |
| 4444      | Blaster Worm      | TCP, UDP | Malware                            |
| 5000      | UPnP              | TCP      | Universal Plug & Play              |
| 5060-5061 | SIP               | TCP, UDP | Session Initiation Protocol (VoIP) |
| 5222-5223 | XMPP              | TCP, UDP | Messaging protocol                 |
| 5432      | PostgreSQL        | TCP      | Database system                    |
| 5900-5999 | VNC               | TCP, UDP | Remote desktop (VNC)               |
| 6379      | Redis             | TCP      | In-memory database                 |
| 6665-6669 | IRC               | TCP      | Internet Relay Chat                |
| 6881-6999 | BitTorrent        | TCP, UDP | File sharing                       |
| 8080      | HTTP Proxy/Alt    | TCP      | Alternate web port                 |
| 8443      | HTTPS Alt         | TCP      | Alternate secure web port          |
| 9042      | Cassandra         | TCP      | NoSQL database                     |
| 9100      | Printer (PDL)     | TCP      | Print Data Stream                  |

---

## 📌 Dynamic / Private Ports (49152 – 65535)

These are used for **ephemeral connections** and **custom apps**.
Safe to use for internal development/testing.

---

## 🎯 Most Common Ports for Exams

If you’re preparing for **CCNA / CompTIA exams**, focus on these:

| Port      | Service    |
| --------- | ---------- |
| 7         | Echo       |
| 20, 21    | FTP        |
| 22        | SSH/SCP    |
| 23        | Telnet     |
| 25        | SMTP       |
| 53        | DNS        |
| 67, 68    | DHCP       |
| 69        | TFTP       |
| 80        | HTTP       |
| 88        | Kerberos   |
| 110       | POP3       |
| 123       | NTP        |
| 137-139   | NetBIOS    |
| 143       | IMAP       |
| 161, 162  | SNMP       |
| 389       | LDAP       |
| 443       | HTTPS      |
| 445       | SMB        |
| 636       | LDAPS      |
| 3389      | RDP        |
| 5060-5061 | SIP (VoIP) |

---

## ✅ Conclusion

Familiarity with ports & protocols is **essential** for:

- Building **secure applications**
- Troubleshooting **network issues**
- Passing **certification exams**

Keep this cheat sheet handy as a quick reference!
