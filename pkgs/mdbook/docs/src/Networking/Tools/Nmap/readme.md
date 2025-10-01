# Nmap Cheat Sheet

> **Quick**: A concise, practical reference for common Nmap workflows — target selection, scan types, discovery, NSE usage, output handling, evasion tricks, and useful one-liners. Designed like a consultant's quick-reference: organized by category so you can scan and apply fast.

---

## Table of contents

1. [Overview & Usage Tips](#overview--usage-tips)
2. [Target Specification](#target-specification)
3. [Scan Techniques](#nmap-scan-techniques)
4. [Host Discovery](#host-discovery)
5. [Port Specification](#port-specification)
6. [Service & Version Detection](#service--version-detection)
7. [OS Detection](#os-detection)
8. [Timing & Performance](#timing--performance)
9. [Timing Tunables](#timing-tunables)
10. [NSE (Nmap Scripting Engine)](#nse-nmap-scripting-engine)
11. [Useful NSE Examples](#useful-nse-examples)
12. [Firewall / IDS Evasion & Spoofing](#firewall--ids-evasion--spoofing)
13. [Output Formats & Options](#output-formats--options)
14. [Helpful Output Examples & Pipelines](#helpful-output-examples--pipelines)
15. [Miscellaneous Flags & Other Commands](#miscellaneous-flags--other-commands)
16. [Practical Tips & Etiquette](#practical-tips--etiquette)

---

## Overview & Usage Tips

- Run Nmap as root (or with sudo) for the most feature-complete scans (e.g., SYN `-sS`, raw packets, OS detection).
- Start with discovery (`-sn`) and light scans (`-T3 -F -sV`) to find live hosts before aggressive options.
- Log results (`-oA`) so you can re-analyze and resume scans later.
- Respect scope & permissions — scanning networks you don't own can be illegal.

---

## Target Specification

Define which IPs/ranges/subnets Nmap should scan.

| Switch / Syntax |                        Example | Description               |
| --------------- | -----------------------------: | ------------------------- |
| Single IP       |             `nmap 192.168.1.1` | Scan a single host        |
| Multiple IPs    | `nmap 192.168.1.1 192.168.2.1` | Scan specific hosts       |
| Range           |         `nmap 192.168.1.1-254` | Scan an IP range          |
| Domain          |         `nmap scanme.nmap.org` | Scan a hostname           |
| CIDR            |          `nmap 192.168.1.0/24` | CIDR subnet scan          |
| `-iL`           |         `nmap -iL targets.txt` | Read targets from file    |
| `-iR`           |                 `nmap -iR 100` | Scan 100 random hosts     |
| `--exclude`     |   `nmap --exclude 192.168.1.1` | Exclude host(s) from scan |

---

## Nmap Scan Techniques

Pick based on stealth, permissions, and speed.

| Switch |                Example | Description                                      |
| ------ | ---------------------: | ------------------------------------------------ |
| `-sS`  | `nmap 192.168.1.1 -sS` | TCP SYN scan (stealthy; default with privileges) |
| `-sT`  | `nmap 192.168.1.1 -sT` | TCP connect() scan (no raw socket required)      |
| `-sU`  | `nmap 192.168.1.1 -sU` | UDP scan                                         |
| `-sA`  | `nmap 192.168.1.1 -sA` | ACK scan (firewall mapping)                      |
| `-sW`  | `nmap 192.168.1.1 -sW` | Window scan                                      |
| `-sM`  | `nmap 192.168.1.1 -sM` | Maimon scan                                      |
| `-A`   |  `nmap 192.168.1.1 -A` | Aggressive — OS, version, scripts, traceroute    |

---

## Host Discovery

Find out which hosts are up before scanning ports or when skipping port scans.

| Switch |                          Example | Description                                          |
| ------ | -------------------------------: | ---------------------------------------------------- |
| `-sL`  |         `nmap 192.168.1.1-3 -sL` | List scan — do not send probes (target listing only) |
| `-sn`  |        `nmap 192.168.1.1/24 -sn` | Ping / host discovery only (no port scan)            |
| `-Pn`  |         `nmap 192.168.1.1-5 -Pn` | Skip host discovery (treat all hosts as up)          |
| `-PS`  | `nmap 192.168.1.1-5 -PS22-25,80` | TCP SYN discovery on specified ports (80 default)    |
| `-PA`  | `nmap 192.168.1.1-5 -PA22-25,80` | TCP ACK discovery on specified ports (80 default)    |
| `-PU`  |       `nmap 192.168.1.1-5 -PU53` | UDP discovery on specified ports (40125 default)     |
| `-PR`  |        `nmap 192.168.1.0/24 -PR` | ARP discovery (local nets only)                      |
| `-n`   |            `nmap 192.168.1.1 -n` | Never perform DNS resolution                         |

---

## Port Specification

Target specific ports, ranges, or mixed TCP/UDP sets.

| Switch              |                               Example | Description                                         |
| ------------------- | ------------------------------------: | --------------------------------------------------- |
| `-p`                |              `nmap 192.168.1.1 -p 21` | Scan single port                                    |
| `-p`                |          `nmap 192.168.1.1 -p 21-100` | Scan port range                                     |
| `-p`                | `nmap 192.168.1.1 -p U:53,T:21-25,80` | Mix UDP and TCP ports                               |
| `-p-`               |                `nmap 192.168.1.1 -p-` | Scan all TCP ports (1–65535)                        |
| Service names       |      `nmap 192.168.1.1 -p http,https` | Use service names instead of numbers                |
| `-F`                |                 `nmap 192.168.1.1 -F` | Fast scan — top 100 ports                           |
| `--top-ports`       |   `nmap 192.168.1.1 --top-ports 2000` | Scan top N ports by frequency                       |
| `-p0-` / `-p-65535` |               `nmap 192.168.1.1 -p0-` | Open-ended ranges; `-p0-` will scan from 0 to 65535 |

---

## Service & Version Detection

Try to identify the service and its version running on discovered ports.

| Switch                    |                                      Example | Description                                           |
| ------------------------- | -------------------------------------------: | ----------------------------------------------------- |
| `-sV`                     |                       `nmap 192.168.1.1 -sV` | Service/version detection                             |
| `-sV --version-intensity` | `nmap 192.168.1.1 -sV --version-intensity 8` | Intensity 0–9. Higher = more probing                  |
| `--version-light`         |       `nmap 192.168.1.1 -sV --version-light` | Lighter/faster detection (less reliable)              |
| `--version-all`           |         `nmap 192.168.1.1 -sV --version-all` | Full (intensity 9) detection                          |
| `-A`                      |                        `nmap 192.168.1.1 -A` | Includes `-sV`, OS detection, NSE scripts, traceroute |

---

## OS Detection

Fingerprint the target TCP/IP stack to guess the OS.

| Switch           |                                Example | Description                                             |
| ---------------- | -------------------------------------: | ------------------------------------------------------- |
| `-O`             |                  `nmap 192.168.1.1 -O` | Remote OS detection (TCP/IP fingerprinting)             |
| `--osscan-limit` |   `nmap 192.168.1.1 -O --osscan-limit` | Skip OS detection unless ports show open/closed pattern |
| `--osscan-guess` |   `nmap 192.168.1.1 -O --osscan-guess` | Be more aggressive about guesses                        |
| `--max-os-tries` | `nmap 192.168.1.1 -O --max-os-tries 1` | Limit how many OS probe attempts are made               |
| `-A`             |                  `nmap 192.168.1.1 -A` | OS detection included with `-A`                         |

---

## Timing & Performance

Built-in timing templates trade off speed vs stealth.

| Switch |                Example | Description                                  |
| ------ | ---------------------: | -------------------------------------------- |
| `-T0`  | `nmap 192.168.1.1 -T0` | Paranoid — max IDS evasion (very slow)       |
| `-T1`  | `nmap 192.168.1.1 -T1` | Sneaky — IDS evasion                         |
| `-T2`  | `nmap 192.168.1.1 -T2` | Polite — reduce bandwidth/CPU usage          |
| `-T3`  | `nmap 192.168.1.1 -T3` | Normal (default)                             |
| `-T4`  | `nmap 192.168.1.1 -T4` | Aggressive — faster but noisier              |
| `-T5`  | `nmap 192.168.1.1 -T5` | Insane — assumes very fast, reliable network |

---

## Timing Tunables (Fine Control)

Adjust timeouts, parallelism, rates and retries.

- `--host-timeout <time>` — give up on a host after this time (e.g., `--host-timeout 2m`).
- `--min-rtt-timeout`, `--max-rtt-timeout`, `--initial-rtt-timeout <time>` — control probe RTT timeouts.
- `--min-hostgroup`, `--max-hostgroup <size>` — group size for parallel host scanning.
- `--min-parallelism`, `--max-parallelism <num>` — probe parallelization controls.
- `--max-retries <tries>` — maximum retransmissions.
- `--min-rate <n>` / `--max-rate <n>` — packet send rate bounds.

Examples:

```bash
nmap --host-timeout 4m --max-retries 2 192.168.1.1
nmap --min-rate 100 --max-rate 1000 -p- 192.168.1.0/24
```

---

## NSE (Nmap Scripting Engine)

Use scripts to automate checks, fingerprinting, vulnerability discovery and enumeration.

| Switch                         |                                                          Example | Notes                                           |
| ------------------------------ | ---------------------------------------------------------------: | ----------------------------------------------- |
| `-sC`                          |                                           `nmap 192.168.1.1 -sC` | Run default safe scripts (convenient discovery) |
| `--script`                     |                                `nmap 192.168.1.1 --script http*` | Run scripts by name or wildcard                 |
| `--script <script1>,<script2>` |                                `nmap --script banner,http-title` | Run specific scripts                            |
| `--script-args`                | `nmap --script snmp-sysdescr --script-args snmpcommunity=public` | Provide args to scripts                         |
| `--script "not intrusive"`     |                      `nmap --script "default and not intrusive"` | Compose script sets (example)                   |

---

## Useful NSE Examples

A few practical one-liners to keep handy.

```bash
# Generate sitemap from web server (HTTP):
nmap -Pn --script=http-sitemap-generator scanme.nmap.org

# Fast random search for web servers:
nmap -n -Pn -p 80 --open -sV -vvv --script banner,http-title -iR 1000

# Brute-force DNS hostnames (subdomain guessing):
nmap -Pn --script=dns-brute domain.com

# Safe SMB enumeration (useful on internal networks):
nmap -n -Pn -vv -O -sV --script smb-enum*,smb-ls,smb-mbenum,smb-os-discovery,smb-vuln* 192.168.1.1

# Whois queries via scripts:
nmap --script whois* domain.com

# Detect XSS-style unsafe output escaping on HTTP port 80:
nmap -p80 --script http-unsafe-output-escaping scanme.nmap.org

# Check for SQL injection (scripted):
nmap -p80 --script http-sql-injection scanme.nmap.org
```

---

## Firewall / IDS Evasion & Spoofing

Techniques to make traffic less obvious. Use responsibly.

| Switch          |                                         Example | Description                                       |
| --------------- | ----------------------------------------------: | ------------------------------------------------- |
| `-f`            |                           `nmap 192.168.1.1 -f` | Fragment packets (can evade some filters)         |
| `--mtu`         |                     `nmap 192.168.1.1 --mtu 32` | Set MTU/fragment size                             |
| `-D`            |        `nmap -D decoy1,decoy2,ME,decoy3 target` | Decoy IP addresses to confuse observers           |
| `-S`            |                        `nmap -S 1.2.3.4 target` | Spoof source IP (may require raw sockets)         |
| `-g`            |                             `nmap -g 53 target` | Set source port (useful to bypass simple filters) |
| `--proxies`     | `nmap --proxies http://192.168.1.1:8080 target` | Relay scans through HTTP/SOCKS proxies            |
| `--data-length` |                 `nmap --data-length 200 target` | Append random data to packets                     |

**Example IDS evasion command**

```bash
nmap -f -T0 -n -Pn --data-length 200 -D 192.168.1.101,192.168.1.102,192.168.1.103,192.168.1.23 192.168.1.1
```

---

## Output Formats & Options

Save scans so you can analyze later or process programmatically.

| Switch            |                            Example | Description                                          |
| ----------------- | ---------------------------------: | ---------------------------------------------------- |
| `-oN`             | `nmap 192.168.1.1 -oN normal.file` | Normal human-readable output file                    |
| `-oX`             |    `nmap 192.168.1.1 -oX xml.file` | XML output (good for parsing)                        |
| `-oG`             |   `nmap 192.168.1.1 -oG grep.file` | Grepable output (legacy)                             |
| `-oA`             |     `nmap 192.168.1.1 -oA results` | Write `results.nmap`, `results.xml`, `results.gnmap` |
| `-oG -`           |           `nmap 192.168.1.1 -oG -` | Print grepable to stdout                             |
| `--append-output` |     `nmap -oN file -append-output` | Append to an existing file                           |
| `-v` / `-vv`      |                          `nmap -v` | Increase verbosity                                   |
| `-d` / `-dd`      |                          `nmap -d` | Increase debugging info                              |
| `--reason`        |                    `nmap --reason` | Show reason a port state was classified              |
| `--open`          |                      `nmap --open` | Show only open or possibly-open ports                |
| `--packet-trace`  |              `nmap --packet-trace` | Show raw packet send/receive detail                  |
| `--iflist`        |                    `nmap --iflist` | List interfaces and routes                           |
| `--resume`        |       `nmap --resume results.file` | Resume an interrupted scan (requires prior save)     |

---

## Helpful Output Examples & Pipelines

Combine Nmap with standard UNIX tools to extract actionable info.

```bash
# Find web servers (HTTP):
nmap -p80 -sV -oG - --open 192.168.1.0/24 | grep open

# Generate list of live hosts from random scan (XML -> grep -> cut):
nmap -iR 10 -n -oX out.xml | grep "Nmap" | cut -d " " -f5 > live-hosts.txt

# Append hosts from second scan:
nmap -iR 10 -n -oX out2.xml | grep "Nmap" | cut -d " " -f5 >> live-hosts.txt

# Compare two scans:
ndiff scan1.xml scan2.xml

# Convert XML to HTML:
xsltproc nmap.xml -o nmap.html

# Frequency of open ports (clean and aggregate):
grep " open " results.nmap | sed -r 's/ +/ /g' | sort | uniq -c | sort -rn | less
```

---

## Miscellaneous Flags

| Switch |                        Example | Description          |
| ------ | -----------------------------: | -------------------- |
| `-6`   | `nmap -6 2607:f0d0:1002:51::4` | Enable IPv6 scanning |
| `-h`   |                      `nmap -h` | Show help screen     |

---

## Other Useful Commands (Mixed Examples)

```bash
# Discovery only on specific TCP ports, no port scan:
nmap -iR 10 -PS22-25,80,113,1050,35000 -v -sn

# ARP-only discovery on local net, verbose, no port scan:
nmap 192.168.1.0/24 -PR -sn -vv

# Traceroute to random targets (no ports):
nmap -iR 10 -sn --traceroute

# List targets only but use internal DNS server:
nmap 192.168.1.1-50 -sL --dns-server 192.168.1.1

# Show packet details during scan:
nmap 192.168.1.1 --packet-trace
```

---

## Practical Tips & Etiquette

- Always have written permission to scan networks you do not own.
- Start small: discovery -> targeted port scan -> version detection -> scripts.
- Use `--script` carefully; some scripts are intrusive.
- Keep a log of what you scanned and when (timestamps help with audits).
- For large networks, break scans into chunks and use `--min-rate/--max-rate` to control load.

---

## Appendix — Quick Command Generator (Examples)

- `nmap -sS -p 1-100 -T4 -oA quick-scan 192.168.1.0/24` — fast SYN scan of top 100 ports, save outputs.
- `nmap -Pn -sV --script=vuln -oX vuln-check.xml 10.0.0.5` — skip host discovery, version & vulnerability scripts.
