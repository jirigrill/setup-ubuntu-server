#!/bin/bash
# install.sh - Main installation script

set -e

source ./scripts/utils.sh

# Check for root/sudo
if [[ $EUID -ne 0 ]] && ! sudo -v; then
    print_error "This script requires sudo privileges"
    exit 1
fi

# Check for .env file
if [ ! -f .env ]; then
    print_error "No .env file found. Please create one from the template."
    exit 1
fi

# Execute installation scripts in order
print_message "Starting installation..."

# Configure user first to ensure sudo access
./scripts/configure_user.sh

# Continue with other installations
./scripts/install_base.sh
./scripts/configure_git.sh
./scripts/install_python.sh
./scripts/install_docker.sh
./scripts/configure_ssh.sh
./scripts/install_zsh.sh

# Ask about disk setup
read -p "Do you want to configure external disks? (y/n): " setup_disks
if [[ $setup_disks == "y" ]]; then
    ./scripts/setup_disks.sh
fi

print_message "Installation complete!"
echo ""
print_warning "Please log out and log back in to start using your new ZSH shell."
echo ""
echo "After logging back in, you'll have:"
echo "1. ZSH as your default shell with Oh My Zsh"
echo "2. Enhanced command-line experience with plugins"
echo "3. Useful aliases and shortcuts"
echo "4. Full administrative access"
echo "5. Python development environment"
echo "6. Docker and development tools"
echo ""
echo "To verify the setup:"
echo "1. Check your shell: echo \$SHELL"
echo "2. Try some ZSH features:"
echo "   - Auto-suggestions (start typing a command)"
echo "   - Syntax highlighting"
echo "   - Git status in prompt"
echo "   - Tab completion"
echo "3. Try the aliases: ll, dps, gc"
