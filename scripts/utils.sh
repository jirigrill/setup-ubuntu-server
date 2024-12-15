#!/bin/bash
# utils.sh - Common utility functions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print status messages
print_message() {
    echo -e "${GREEN}[*] $1${NC}"
}

# Function to print warnings
print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Function to print errors
print_error() {
    echo -e "${RED}[✘] $1${NC}"
}

# Function to check if command was successful
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✔] $1 completed successfully${NC}"
    else
        echo -e "${RED}[✘] $1 failed${NC}"
        exit 1
    fi
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root or with sudo"
        exit 1
    fi
}
