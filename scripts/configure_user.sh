#!/bin/bash
# configure_user.sh - User privileges and sudo setup

set -e

source ./scripts/utils.sh
source .env

print_message "Configuring user privileges for ${USERNAME}..."

# Add user to basic system groups first
print_message "Adding user to system groups..."
sudo usermod -aG sudo,adm,netdev,plugdev,video,audio ${USERNAME}
check_status "Group modification"

# Configure sudo without password
print_message "Configuring sudo access..."
echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/personal
sudo chmod 440 /etc/sudoers.d/personal
check_status "Sudo configuration"

print_message "Basic user configuration complete!"
print_warning "Docker group will be added during Docker installation"
