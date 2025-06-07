# 🧪 Linux Privilege Escalation Lab (2-VM Setup)

A hands-on red team lab demonstrating normal and advanced Linux privilege escalation techniques. Built with attacker-victim VM model using Linux Mint (victim) and Parrot OS (attacker). Includes real-world misconfigurations and custom SUID/systemd/capability abuse vectors.

---

## 🧠 Lab Overview

- **Victim OS**: Linux Mint (local VM)
- **Attacker OS**: Parrot OS (local VM)
- **VM Count**: 2 total (host-only networking)
- **Entry Point**: SSH into `intern@victim`
- **Goal**: Escalate from `intern` → `root` using planted vulnerabilities

---

## 🧰 Features Planted

| Technique                  | Description                            |
|---------------------------|----------------------------------------|
| SUID binary               | `/usr/local/bin/suidbash`              |
| Writable `/etc/passwd`    | Allows UID 0 injection                 |
| Sudo misconfig            | `vim` allowed with NOPASSWD            |
| Netcat with `setcap`      | Bind to port 80 without root           |
| Writable systemd service  | Modifiable `ExecStart`                 |
| Leaked secret config      | `/etc/secret.env`                      |

---

## ⚙️ Setup Instructions

```bash
git clone https://github.com/ibernal1815/linux-privilege-escalation-lab.git
cd linux-privilege-escalation-lab
sudo bash setup-vulnerabilities.sh
