#!/bin/bash
# setup_disks.sh - External disk configuration

set -e

source ./scripts/utils.sh
source .env

function setup_disk() {
    local device=$1
    local label=$2
    local mount_point=$3

    print_message "Setting up disk ${device} with label ${label}..."
    
    # Verify disk exists
    if [ ! -b "/dev/${device}" ]; then
        print_error "Device /dev/${device} not found"
        exit 1
    }
    
    # Check if disk is mounted
    if mount | grep -q "^/dev/${device}"; then
        print_warning "Disk /dev/${device} is mounted. Unmounting..."
        sudo umount "/dev/${device}"*
    fi
    
    # Format disk
    print_warning "This will format /dev/${device} with label ${label}"
    read -p "Are you sure you want to continue? (y/n): " confirm
    if [[ $confirm != "y" ]]; then
        print_message "Skipping disk ${device}"
        return
    fi
    
    sudo mkfs.ext4 -L "${label}" "/dev/${device}"
    
    # Create mount point
    sudo mkdir -p "${mount_point}"
    
    # Get UUID
    local uuid=$(sudo blkid -s UUID -o value "/dev/${device}")
    
    # Add to fstab if not already present
    if ! grep -q "${uuid}" /etc/fstab; then
        echo "UUID=${uuid} ${mount_point} ext4 defaults 0 2" | sudo tee -a /etc/fstab
    fi
    
    check_status "Disk ${device} setup"
}

# List available disks
print_message "Available disks:"
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINT

# Get disk information
echo ""
print_message "Please specify the disk devices to use (e.g., sdb1, sdc1):"
read -p "Enter device name for first disk: " disk1
read -p "Enter label for first disk [media1]: " label1
label1=${label1:-media1}
read -p "Enter mount point for first disk [/mnt/disk1]: " mount1
mount1=${mount1:-/mnt/disk1}

read -p "Enter device name for second disk: " disk2
read -p "Enter label for second disk [media2]: " label2
label2=${label2:-media2}
read -p "Enter mount point for second disk [/mnt/disk2]: " mount2
mount2=${mount2:-/mnt/disk2}

# Setup disks
setup_disk "${disk1}" "${label1}" "${mount1}"
setup_disk "${disk2}" "${label2}" "${mount2}"

# Mount all
sudo mount -a
check_status "Disk mounting"

# Verify setup
print_message "Final disk configuration:"
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINT

# Set permissions
print_message "Setting disk permissions..."
sudo chown -R ${USERNAME}:${USERNAME} "${mount1}" "${mount2}"
check_status "Permissions setup"

print_message "Disk setup complete!"
echo "Disks are mounted at:"
echo "1. ${mount1}"
echo "2. ${mount2}"
echo ""
echo "To check disk space: df -h"
echo "To check disk usage: du -h <directory>"
