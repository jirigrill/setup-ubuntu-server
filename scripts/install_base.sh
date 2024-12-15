#!/bin/bash
# install_base.sh - Basic system setup and package installation

set -e

source ./scripts/utils.sh
source .env

# Update system
print_message "Updating system packages..."
sudo apt update && sudo apt upgrade -y
check_status "System update"

# Configure timezone and locale
print_message "Configuring timezone and locale..."
sudo timedatectl set-timezone ${TIMEZONE}
sudo locale-gen ${LANG}
sudo update-locale LANG=${LANG} LC_ALL=${LC_ALL}

# Create or update environment file
sudo tee /etc/environment > /dev/null << EOF
LANG=${LANG}
LC_ALL=${LC_ALL}
TZ=${TIMEZONE}
EOF

check_status "System configuration"

# System Monitoring
print_message "Installing system monitoring tools..."
sudo apt install -y \
    neofetch \
    glances \
    iotop \
    htop \
    nmon \
    ncdu
check_status "System monitoring tools"

# Network Tools
print_message "Installing network tools..."
sudo apt install -y \
    net-tools \
    dnsutils \
    mtr \
    netcat \
    rsync
check_status "Network tools"

# Development Tools
print_message "Installing development tools..."
sudo apt install -y \
    git \
    vim \
    tree \
    nodejs \
    npm
check_status "Development tools"

# Database Tools
print_message "Installing database tools..."
sudo apt install -y \
    postgresql \
    sqlite3 \
    redis-tools
check_status "Database tools"

# Data Processing
print_message "Installing data processing tools..."
sudo apt install -y jq
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod a+x /usr/local/bin/yq
check_status "Data processing tools"

# Terminal Utilities
print_message "Installing terminal utilities..."
sudo apt install -y \
    zsh \
    tmux \
    screen
check_status "Terminal utilities"

# Security Tools
print_message "Installing security tools..."
sudo apt install -y \
    fail2ban \
    ufw
check_status "Security tools"

# Create directory structure
print_message "Creating directories..."
mkdir -p ${DEV_DIR} ${LOG_DIR} ${BACKUP_DIR}
check_status "Directory creation"
