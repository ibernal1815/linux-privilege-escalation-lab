#!/bin/bash

# ---------------------------------------------
# Linux PE Lab: Cleanup Vulnerability Artifacts
# ---------------------------------------------
# Reverts changes made by setup-vulnerabilities.sh
# Tested on Linux Mint / Ubuntu

echo "[*] Starting cleanup..."

# Remove SUID Bash Binary
if [ -f /usr/local/bin/suidbash ]; then
    echo "[*] Removing SUID bash binary..."
    rm -f /usr/local/bin/suidbash
fi

# Fix /etc/passwd permissions
echo "[*] Restoring /etc/passwd permissions..."
chmod 644 /etc/passwd

# Remove backdoor users from /etc/passwd
echo "[*] Cleaning up added root users..."
sed -i '/^hacked::0:0/d' /etc/passwd

# Remove sudoers entry for intern (vim)
echo "[*] Removing sudoers rule for intern and vim..."
sed -i '/intern ALL=(ALL) NOPASSWD: \/usr\/bin\/vim/d' /etc/sudoers

# Remove leaked config file
if [ -f /etc/secret.env ]; then
    echo "[*] Deleting leaked secret.env..."
    rm -f /etc/secret.env
fi

# Remove writable systemd service
if [ -f /etc/systemd/system/vuln.service ]; then
    echo "[*] Deleting vulnerable systemd service..."
    rm -f /etc/systemd/system/vuln.service
    systemctl daemon-reload
fi

# Remove SUID-rooted binary
if [ -f /tmp/rooted ]; then
    echo "[*] Removing rooted SUID binary..."
    rm -f /tmp/rooted
fi

# Remove Netcat capability
echo "[*] Removing setcap from netcat..."
setcap -r /usr/bin/nc.traditional 2>/dev/null

echo "[+] Cleanup complete. System restored."
