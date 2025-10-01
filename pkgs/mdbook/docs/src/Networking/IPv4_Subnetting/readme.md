# IPv4 Subnetting Cheat Sheet

Subnetting is one of the most fundamental yet challenging concepts in networking. This cheat sheet provides quick references to help you master IPv4 subnetting for certifications, administration, and network design.

---

## IPv4 Subnets

Subnetting allows a host to determine if the destination machine is local or remote. The subnet mask determines how many IPv4 addresses are assignable within a network.

| CIDR | Subnet Mask     | # of Addresses | Wildcard        |
| ---- | --------------- | -------------- | --------------- |
| /32  | 255.255.255.255 | 1              | 0.0.0.0         |
| /31  | 255.255.255.254 | 2              | 0.0.0.1         |
| /30  | 255.255.255.252 | 4              | 0.0.0.3         |
| /29  | 255.255.255.248 | 8              | 0.0.0.7         |
| /28  | 255.255.255.240 | 16             | 0.0.0.15        |
| /27  | 255.255.255.224 | 32             | 0.0.0.31        |
| /26  | 255.255.255.192 | 64             | 0.0.0.63        |
| /25  | 255.255.255.128 | 128            | 0.0.0.127       |
| /24  | 255.255.255.0   | 256            | 0.0.0.255       |
| /23  | 255.255.254.0   | 512            | 0.0.1.255       |
| /22  | 255.255.252.0   | 1024           | 0.0.3.255       |
| /21  | 255.255.248.0   | 2,048          | 0.0.7.255       |
| /20  | 255.255.240.0   | 4,096          | 0.0.15.255      |
| /19  | 255.255.224.0   | 8,192          | 0.0.31.255      |
| /18  | 255.255.192.0   | 16,384         | 0.0.63.255      |
| /17  | 255.255.128.0   | 32,768         | 0.0.127.255     |
| /16  | 255.255.0.0     | 65,536         | 0.0.255.255     |
| /15  | 255.254.0.0     | 131,072        | 0.1.255.255     |
| /14  | 255.252.0.0     | 262,144        | 0.3.255.255     |
| /13  | 255.248.0.0     | 524,288        | 0.7.255.255     |
| /12  | 255.240.0.0     | 1,048,576      | 0.15.255.255    |
| /11  | 255.224.0.0     | 2,097,152      | 0.31.255.255    |
| /10  | 255.192.0.0     | 4,194,304      | 0.63.255.255    |
| /9   | 255.128.0.0     | 8,388,608      | 0.127.255.255   |
| /8   | 255.0.0.0       | 16,777,216     | 0.255.255.255   |
| /7   | 254.0.0.0       | 33,554,432     | 1.255.255.255   |
| /6   | 252.0.0.0       | 67,108,864     | 3.255.255.255   |
| /5   | 248.0.0.0       | 134,217,728    | 7.255.255.255   |
| /4   | 240.0.0.0       | 268,435,456    | 15.255.255.255  |
| /3   | 224.0.0.0       | 536,870,912    | 31.255.255.255  |
| /2   | 192.0.0.0       | 1,073,741,824  | 63.255.255.255  |
| /1   | 128.0.0.0       | 2,147,483,648  | 127.255.255.255 |
| /0   | 0.0.0.0         | 4,294,967,296  | 255.255.255.255 |

---

## Decimal to Binary Conversion

IPv4 addresses are actually 32-bit binary numbers. Subnet masks in binary show which part is the network and which part is the host.

| Subnet Mask | Binary    | Wildcard | Binary Wildcard |
| ----------- | --------- | -------- | --------------- |
| 255         | 1111 1111 | 0        | 0000 0000       |
| 254         | 1111 1110 | 1        | 0000 0001       |
| 252         | 1111 1100 | 3        | 0000 0011       |
| 248         | 1111 1000 | 7        | 0000 0111       |
| 240         | 1111 0000 | 15       | 0000 1111       |
| 224         | 1110 0000 | 31       | 0001 1111       |
| 192         | 1100 0000 | 63       | 0011 1111       |
| 128         | 1000 0000 | 127      | 0111 1111       |
| 0           | 0000 0000 | 255      | 1111 1111       |

### Why Learn Binary?

- `1` = Network portion
- `0` = Host portion
- Subnet masks must have all ones followed by all zeros.

**Example:** A `/24` (255.255.255.0) subnet reserves 24 bits for network and 8 bits for hosts → 254 usable IPs.

**/28 Example:** If ISP gives `199.44.6.80/28`, you calculate host addresses by binary increments → usable range = `.81 - .94`.

---

## IPv4 Address Classes

| Class | Range                       |
| ----- | --------------------------- |
| A     | 0.0.0.0 – 127.255.255.255   |
| B     | 128.0.0.0 – 191.255.255.255 |
| C     | 192.0.0.0 – 223.255.255.255 |
| D     | 224.0.0.0 – 239.255.255.255 |
| E     | 240.0.0.0 – 255.255.255.255 |

---

## Reserved (Private) Ranges

| Range Type       | IP Range                      |
| ---------------- | ----------------------------- |
| Class A          | 10.0.0.0 – 10.255.255.255     |
| Class B          | 172.16.0.0 – 172.31.255.255   |
| Class C          | 192.168.0.0 – 192.168.255.255 |
| Localhost        | 127.0.0.0 – 127.255.255.255   |
| Zeroconf (APIPA) | 169.254.0.0 – 169.254.255.255 |

---

## Key Terminology

- **Wildcard Mask:** Indicates available address bits for matching.
- **CIDR:** Classless Inter-Domain Routing, uses `/XX` notation.
- **Network Portion:** Fixed part of IP determined by subnet mask.
- **Host Portion:** Variable part of IP usable for devices.

---

## Conclusion

IPv4 subnetting can seem complex, but with practice and binary understanding, it becomes second nature. Keep this sheet handy for quick reference during exams, troubleshooting, or design work.
