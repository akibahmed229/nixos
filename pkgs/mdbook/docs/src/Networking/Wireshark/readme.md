Got it 🚀 — I’ll refactor your raw Wireshark cheat sheet into a clean **Markdown (`.md`) file format**.

Here’s the structured version:

---

# Wireshark Cheat Sheet

Wireshark is one of the most popular and powerful tools for capturing, analyzing, and troubleshooting network traffic.

Whether you are a **network administrator**, **security professional**, or just someone curious about how networks work, learning Wireshark is a valuable skill.
This cheat sheet serves as a quick reference for filters, commands, shortcuts, and syntax.

---

## 📊 Default Columns in Packet Capture

| Name                  | Description                                           |
| --------------------- | ----------------------------------------------------- |
| **No.**               | Frame number from the beginning of the packet capture |
| **Time**              | Seconds from the first frame                          |
| **Source (src)**      | Source address (IPv4, IPv6, or Ethernet)              |
| **Destination (dst)** | Destination address                                   |
| **Protocol**          | Protocol in Ethernet/IP/TCP segment                   |
| **Length**            | Frame length in bytes                                 |

---

## 🔎 Logical Operators

| Operator        | Description        | Example                            |            |                                |
| --------------- | ------------------ | ---------------------------------- | ---------- | ------------------------------ |
| `and` / `&&`    | Logical AND        | All conditions must match          |            |                                |
| `or` / `        |                    | `                                  | Logical OR | At least one condition matches |
| `xor` / `^^`    | Logical XOR        | Only one of two conditions matches |            |                                |
| `not` / `!`     | Negation           | Exclude packets                    |            |                                |
| `[n]` `[ ... ]` | Substring operator | Match specific text                |            |                                |

---

## 🎯 Filtering Packets (Display Filters)

| Operator    | Description      | Example                  |
| ----------- | ---------------- | ------------------------ |
| `eq` / `==` | Equal            | `ip.dest == 192.168.1.1` |
| `ne` / `!=` | Not equal        | `ip.dest != 192.168.1.1` |
| `gt` / `>`  | Greater than     | `frame.len > 10`         |
| `lt` / `<`  | Less than        | `frame.len < 10`         |
| `ge` / `>=` | Greater or equal | `frame.len >= 10`        |
| `le` / `<=` | Less or equal    | `frame.len <= 10`        |

---

## 🧩 Filter Types

| Name               | Description                        |
| ------------------ | ---------------------------------- |
| **Capture filter** | Applied during capture             |
| **Display filter** | Applied to hide/show after capture |

---

## 📡 Capturing Modes

| Mode                 | Description                                    |
| -------------------- | ---------------------------------------------- |
| **Promiscuous mode** | Capture all packets on the segment             |
| **Monitor mode**     | Capture all wireless traffic (Linux/Unix only) |

---

## ⚡ Miscellaneous

- **Slice Operator** → `[ ... ]` (range)
- **Membership Operator** → `{}` (in)
- **Ctrl+E** → Start/Stop capturing

---

## 🔐 Capture Filter Syntax

**Example:**

```wireshark
tcp src 192.168.1.1 and tcp dst 202.164.30.1
```

---

## 🎨 Display Filter Syntax

**Example:**

```wireshark
http and ip.dst == 192.168.1.1 and tcp.port
```

---

## ⌨️ Keyboard Shortcuts (Main Window)

| Shortcut            | Action                          |
| ------------------- | ------------------------------- |
| `Tab` / `Shift+Tab` | Move between UI elements        |
| `↓` / `↑`           | Move between packets/details    |
| `Ctrl+↓` / `F8`     | Next packet (even if unfocused) |
| `Ctrl+↑` / `F7`     | Previous packet                 |
| `Ctrl+.`            | Next packet in conversation     |
| `Ctrl+,`            | Previous packet in conversation |
| `Return` / `Enter`  | Toggle tree item                |
| `Backspace`         | Jump to parent node             |

---

## 📑 Protocol Values

```
ether, fddi, ip, arp, rarp, decnet, lat, sca, moprc, mopdl, tcp, udp
```

---

## 🔍 Common Filtering Commands

| Usage            | Syntax                                              |
| ---------------- | --------------------------------------------------- |
| Filter by IP     | `ip.addr == 10.10.50.1`                             |
| Destination IP   | `ip.dest == 10.10.50.1`                             |
| Source IP        | `ip.src == 10.10.50.1`                              |
| IP range         | `ip.addr >= 10.10.50.1 and ip.addr <= 10.10.50.100` |
| Multiple IPs     | `ip.addr == 10.10.50.1 and ip.addr == 10.10.50.100` |
| Exclude IP       | `!(ip.addr == 10.10.50.1)`                          |
| Subnet           | `ip.addr == 10.10.50.1/24`                          |
| Port             | `tcp.port == 25`                                    |
| Destination port | `tcp.dstport == 23`                                 |
| IP + Port        | `ip.addr == 10.10.50.1 and tcp.port == 25`          |
| URL              | `http.host == "hostname"`                           |
| Time             | `frame.time >= "June 02, 2019 18:04:00"`            |
| SYN flag         | `tcp.flags.syn == 1 and tcp.flags.ack == 0`         |
| Beacon frames    | `wlan.fc.type_subtype == 0x08`                      |
| Broadcast        | `eth.dst == ff:ff:ff:ff:ff:ff`                      |
| Multicast        | `(eth.dst[0] & 1)`                                  |
| Hostname         | `ip.host == hostname`                               |
| MAC address      | `eth.addr == 00:70:f4:23:18:c4`                     |
| RST flag         | `tcp.flag.reset == 1`                               |

---

## 🛠️ Main Toolbar Items

| Icon | Item               | Menu                  | Description             |
| ---- | ------------------ | --------------------- | ----------------------- |
| ▶️   | **Start**          | Capture → Start       | Begin capture           |
| ⏹️   | **Stop**           | Capture → Stop        | Stop capture            |
| 🔄   | **Restart**        | Capture → Restart     | Restart session         |
| ⚙️   | **Options**        | Capture → Options…    | Capture options dialog  |
| 📂   | **Open**           | File → Open…          | Load capture file       |
| 💾   | **Save As**        | File → Save As…       | Save capture file       |
| ❌   | **Close**          | File → Close          | Close current capture   |
| 🔄   | **Reload**         | View → Reload         | Reload capture file     |
| 🔍   | **Find Packet**    | Edit → Find Packet…   | Search packets          |
| ⏪   | **Go Back**        | Go → Back             | Jump back in history    |
| ⏩   | **Go Forward**     | Go → Forward          | Jump forward            |
| 🔝   | **Go to Packet**   | Go → Packet           | Jump to specific packet |
| ↩️   | **First Packet**   | Go → First Packet     | Jump to first packet    |
| ↪️   | **Last Packet**    | Go → Last Packet      | Jump to last packet     |
| 📜   | **Auto Scroll**    | View → Auto Scroll    | Scroll live capture     |
| 🎨   | **Colorize**       | View → Colorize       | Colorize packet list    |
| 🔎   | **Zoom In/Out**    | View → Zoom In/Out    | Adjust zoom level       |
| 🔲   | **Normal Size**    | View → Normal Size    | Reset zoom              |
| 📏   | **Resize Columns** | View → Resize Columns | Fit column width        |

---

## ✅ Conclusion

Wireshark is an incredibly powerful tool for analyzing and troubleshooting network traffic.
This cheat sheet gives you **commands, filters, and shortcuts** to navigate Wireshark efficiently and quickly.
