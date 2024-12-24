#!/bin/bash
# setup_disks.sh - External disk configuration

set -e

source ./scripts/utils.sh
source .env

function is_system_disk() {
    local device=$1
    
    # Check if disk contains root partition
    if mount | grep "^/dev/${device}" | grep -q " / "; then
        return 0
    fi
    
    # Check if disk contains boot partition
    if mount | grep "^/dev/${device}" | grep -q " /boot"; then
        return 0
    fi
    
    # Check if disk contains EFI partition
    if mount | grep "^/dev/${device}" | grep -q " /boot/efi"; then
        return 0
    fi
    
    # Check if disk is part of LVM system
    if pvs 2>/dev/null | grep -q "/dev/${device}"; then
        return 0
    fi
    
    return 1
}

function get_disk_info() {
    local device=$1
    
    echo "Disk details for /dev/${device}:"
    echo "--------------------------------"
    lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "/dev/${device}"
    echo "--------------------------------"
    
    # Show partition table
    echo "Partition table:"
    sudo fdisk -l "/dev/${device}" 2>/dev/null || true
    echo "--------------------------------"
}

function change_label() {
    local device=$1
    local new_label=$2
    
    # Verify disk exists
    if [ ! -b "/dev/${device}" ]; then
        print_error "Device /dev/${device} not found"
        return 1
    fi
    
    # Get current filesystem type
    local fstype=$(lsblk -no FSTYPE "/dev/${device}")
    if [ -z "$fstype" ]; then
        print_error "No filesystem found on /dev/${device}"
        return 1
    fi
    
    print_message "Current filesystem type: ${fstype}"
    
    # Change label based on filesystem type
    case $fstype in
        ext4|ext3|ext2)
            sudo e2label "/dev/${device}" "${new_label}"
            ;;
        xfs)
            sudo xfs_admin -L "${new_label}" "/dev/${device}"
            ;;
        vfat)
            sudo fatlabel "/dev/${device}" "${new_label}"
            ;;
        ntfs)
            sudo ntfslabel "/dev/${device}" "${new_label}"
            ;;
        *)
            print_error "Unsupported filesystem type: ${fstype}"
            return 1
            ;;
    esac
    
    print_message "Label changed successfully to: ${new_label}"
    
    # Show new disk info
    lsblk -o NAME,LABEL,FSTYPE "/dev/${device}"
    return 0
}

function setup_disk() {
    local device=$1
    local label=$2
    local mount_point=$3

    print_message "Setting up disk ${device} with label ${label}..."

    # Verify disk exists
    if [ ! -b "/dev/${device}" ]; then
        print_error "Device /dev/${device} not found"
        exit 1
    fi

    # Show disk information
    get_disk_info "${device}"

    # Critical safety check for system disks
    if is_system_disk "${device}"; then
        print_error "ERROR: /dev/${device} appears to be a system disk!"
        echo "This disk contains system partitions or is part of the system LVM."
        echo "Modifying this disk could make your system unbootable."
        echo "Please double-check and use a different disk."
        exit 1
    fi

    # Additional warning for full disk devices (like sda instead of sda1)
    if ! [[ ${device} =~ [0-9]$ ]]; then
        print_warning "WARNING: You specified a full disk device (${device}) rather than a partition"
        print_warning "This could be dangerous if the disk contains existing partitions"
        echo "Current partitions on ${device}:"
        lsblk "/dev/${device}"
        read -p "Do you want to continue with the full disk? Type 'I understand' to proceed: " full_disk_confirm
        if [[ $full_disk_confirm != "I understand" ]]; then
            print_message "Aborting operation"
            exit 1
        fi
    fi

    # Check if disk is mounted
    if mount | grep -q "^/dev/${device}"; then
        print_warning "Disk /dev/${device} is mounted. Unmounting..."
        sudo umount "/dev/${device}"*
    fi

    # Check if disk is already formatted
    local current_fstype=$(lsblk -no FSTYPE "/dev/${device}")
    if [ -n "$current_fstype" ]; then
        print_message "Disk is already formatted as ${current_fstype}"
        
        # Add option to change label without reformatting
        read -p "Do you want to change the label without reformatting? (y/n): " change_label_only
        if [[ $change_label_only == "y" ]]; then
            if change_label "${device}" "${label}"; then
                print_message "Label changed successfully"
            else
                print_error "Failed to change label"
                return 1
            fi
        else
            read -p "Do you want to reformat the disk? This will ERASE ALL DATA (y/n): " format_disk
            if [[ $format_disk != "y" ]]; then
                print_message "Skipping format for ${device}"
            else
                # Format disk
                print_warning "This will format /dev/${device} with label ${label}"
                read -p "Are you ABSOLUTELY SURE you want to format? Type 'YES FORMAT' to confirm: " confirm
                if [[ $confirm != "YES FORMAT" ]]; then
                    print_message "Skipping format for ${device}"
                else
                    sudo mkfs.ext4 -L "${label}" "/dev/${device}"
                fi
            fi
        fi
    else
        print_message "Disk is not formatted"
        read -p "Do you want to format the disk as ext4? (y/n): " format_disk
        if [[ $format_disk == "y" ]]; then
            sudo mkfs.ext4 -L "${label}" "/dev/${device}"
        else
            print_error "Cannot continue without a formatted disk"
            return 1
        fi
    fi

    # Create mount point
    sudo mkdir -p "${mount_point}"

    # Get UUID
    local uuid=$(sudo blkid -s UUID -o value "/dev/${device}")
    
    if [ -z "$uuid" ]; then
        print_error "Could not get UUID for ${device}. Is it formatted?"
        return 1
    fi

    # Add to fstab if not already present
    if ! grep -q "${uuid}" /etc/fstab; then
        echo "UUID=${uuid} ${mount_point} ext4 defaults 0 2" | sudo tee -a /etc/fstab
    fi

    check_status "Disk ${device} setup"
}

# Add option to only change label at the beginning
print_message "Available operations:"
echo "1. Setup disk (format, mount, etc.)"
echo "2. Change label only"
read -p "Select operation (1/2): " operation

case $operation in
    1)
        # Original disk setup functionality
        print_message "WARNING: This script modifies disk partitions and filesystems."
        print_message "Make sure you have backups before proceeding."
        echo ""

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

        read -p "Do you want to setup a second disk? (y/n): " setup_second
        if [[ $setup_second == "y" ]]; then
            read -p "Enter device name for second disk: " disk2
            read -p "Enter label for second disk [media2]: " label2
            label2=${label2:-media2}
            read -p "Enter mount point for second disk [/mnt/disk2]: " mount2
            mount2=${mount2:-/mnt/disk2}
        fi

        # Setup disks
        setup_disk "${disk1}" "${label1}" "${mount1}"
        if [[ $setup_second == "y" ]]; then
            setup_disk "${disk2}" "${label2}" "${mount2}"
        fi

        # Mount all
        sudo mount -a
        check_status "Disk mounting"

        # Verify setup
        print_message "Final disk configuration:"
        lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINT

        # Set permissions
        print_message "Setting disk permissions..."
        if [[ $setup_second == "y" ]]; then
            sudo chown -R ${USERNAME}:${USERNAME} "${mount1}" "${mount2}"
        else
            sudo chown -R ${USERNAME}:${USERNAME} "${mount1}"
        fi
        check_status "Permissions setup"

        print_message "Disk setup complete!"
        echo "Disks are mounted at:"
        echo "1. ${mount1}"
        if [[ $setup_second == "y" ]]; then
            echo "2. ${mount2}"
        fi
        echo ""
        echo "To check disk space: df -h"
        echo "To check disk usage: du -h <directory>"
        ;;
    2)
        # Label changing functionality
        print_message "Available disks:"
        lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINT
        echo ""
        read -p "Enter device name (e.g., sdb1): " device
        read -p "Enter new label: " new_label
        change_label "${device}" "${new_label}"
        ;;
    *)
        print_error "Invalid operation selected"
        exit 1
        ;;
esac
