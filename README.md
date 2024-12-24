# Linux Development Environment Setup

A collection of shell scripts to automate the setup of a Linux development environment with common tools and configurations.

## Features

- Automated system configuration
- Development tools installation
- Python environment setup with multiple versions
- Docker and Docker Compose installation
- SSH server configuration
- ZSH shell with Oh My Zsh
- External disk management
- Git configuration

## Prerequisites

- A Debian-based Linux distribution (Ubuntu, Debian)
- sudo privileges
- Internet connection

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/dev-setup
cd dev-setup
```

2. Create `.env` file from template:
```bash
cp .env.example .env
```

3. Run the installation:
```bash
./install.sh
```

## Configuration

Create a `.env` file with your preferences. Example configuration:

```bash
# System Configuration
TIMEZONE=UTC
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
TIME_FORMAT=24
PUID=1000
PGID=1000
USERNAME=devuser

# Python Configuration
PYTHON_VERSIONS="3.11.0 3.12.0"
PYTHON_DEFAULT="3.12.0"
PYTHON_PACKAGES="pytest black flake8 requests pandas"

# SSH Configuration
SSH_PORT=2222
PERMIT_ROOT_LOGIN=no
PASSWORD_AUTHENTICATION=yes

# Directory Structure
DEV_DIR=/path/to/code
LOG_DIR=/path/to/logs
BACKUP_DIR=/path/to/backups

# Docker Configuration
DOCKER_COMPOSE_VERSION=latest

# Security Configuration
ENABLE_UFW=yes
ENABLE_FAIL2BAN=yes
```

## Components

### Base System Setup
- System updates and upgrades
- Essential development tools
- Network utilities
- Monitoring tools
- Security packages

### Python Environment
- Multiple Python versions via pyenv
- Common development packages
- Virtual environment support

### Docker Setup
- Docker Engine
- Docker Compose
- User group configuration
- Logging configuration

### ZSH Configuration
- Oh My Zsh installation
- Custom plugins
- Useful aliases
- Development-focused theme

### Git Configuration
- Global settings
- Useful aliases
- Default branch configuration
- Global gitignore

### External Disk Management
- Disk formatting
- Mount point creation
- Filesystem labeling
- fstab configuration

## Directory Structure

```
.
├── install.sh
├── .env.example
├── .gitignore
└── scripts/
    ├── utils.sh
    ├── install_base.sh
    ├── install_python.sh
    ├── install_docker.sh
    ├── install_zsh.sh
    ├── configure_git.sh
    ├── configure_ssh.sh
    ├── configure_user.sh
    └── setup_disks.sh
```

## Usage

### Basic Installation

```bash
./install.sh
```

### Individual Components

You can run individual scripts for specific setups:

```bash
./scripts/install_python.sh  # Python environment only
./scripts/install_docker.sh  # Docker setup only
./scripts/setup_disks.sh    # Disk configuration only
```

## Post-Installation

After installation:

1. Log out and log back in to start using ZSH
2. Verify Docker installation: `docker --version`
3. Check Python setup: `python --version`
4. Verify Git configuration: `git config --list`

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Security Notes

- Change default SSH port and configurations
- Review and adjust UFW rules
- Modify fail2ban configuration as needed
- Keep system and packages updated
