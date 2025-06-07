#!/bin/bash

# ---------------------------------------------------------------------
# Linux Privilege Escalation Lab Setup Script
# Tested on Linux Mint, Ubuntu-based systems
# ---------------------------------------------------------------------
# Creates a low-privilege user, installs tools, and introduces common PE flaws
# ---------------------------------------------------------------------

set -e

echo "[*] Creating low-privilege user: intern"
useradd -m -s /bin/bash intern || echo "[!] User 'intern' already exists"
echo "intern:password" | chpasswd

echo "[*] Installing required packages..."
apt update && apt install -y \
    netcat-traditional \
    vim \
    systemd \
    wget \
    curl \
    sudo \
    bash

# -------------------------------
# SUID Bash Binary
# -------------------------------
echo "[*] Planting SUID bash binary at /usr/local/bin/suidbash"
cp /bin/bash /usr/local/bin/suidbash
chmod u+s /usr/local/bin/suidbash

# -------------------------------
# Writable /etc/passwd
# -------------------------------
echo "[*] Making /etc/passwd world-writable (insecure)"
chmod o+w /etc/passwd

# -------------------------------
# Sudo Misconfig (vim)
# -------------------------------
echo "[*] Granting sudo access to intern for /usr/bin/vim"
echo "intern ALL=(ALL) NOPASSWD: /usr/bin/vim" >> /etc/sudoers

# -------------------------------
# Netcat Bind Capability
# -------------------------------
echo "[*] Adding cap_net_bind_service to nc.traditional"
setcap cap_net_bind_service=+ep /usr/bin/nc.traditional || echo "[!] setcap failed"

# -------------------------------
# Leaked Config File
# -------------------------------
echo "[*] Writing leaked secret to /etc/secret.env"
echo -e "DB_USER=root\nDB_PASS=SuperSecret123" > /etc/secret.env
chmod 644 /etc/secret.env

# -------------------------------
# Writable systemd service
# -------------------------------
echo "[*] Creating writable systemd service"
cat <<EOF > /etc/systemd/system/vuln.service
[Unit]
Description=Vulnerable Custom Service

[Service]
ExecStart=/usr/bin/sleep 99999

[Install]
WantedBy=multi-user.target
EOF

chown root:intern /etc/systemd/system/vuln.service
chmod 664 /etc/systemd/system/vuln.service

# -------------------------------
# Enable SSH (for remote attacks)
# -------------------------------
echo "[*] Ensuring SSH is enabled"
systemctl enable ssh
systemctl start ssh

# -------------------------------
# Summary
# -------------------------------
echo
echo "[+] Setup complete!"
echo "[+] User: intern | Password: password"
echo "[+] SUID bash at: /usr/local/bin/suidbash"
echo "[+] Sudo rule: vim as root"
echo "[+] Writable passwd file"
echo "[+] Netcat bind shell enabled on port 80"
echo "[+] Leaked creds in /etc/secret.env"
echo "[+] Writable systemd service at /etc/systemd/system/vuln.service"
