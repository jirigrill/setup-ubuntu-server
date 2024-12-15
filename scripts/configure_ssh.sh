#!/bin/bash
# configure_ssh.sh - SSH server configuration

set -e

source ./scripts/utils.sh
source .env

print_message "Configuring SSH..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

sudo tee /etc/ssh/sshd_config > /dev/null << EOF
Port ${SSH_PORT}
Protocol 2
PermitRootLogin ${PERMIT_ROOT_LOGIN}
PasswordAuthentication ${PASSWORD_AUTHENTICATION}
PubkeyAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_* TZ
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

# Restart SSH service
sudo systemctl restart ssh
check_status "SSH configuration"
