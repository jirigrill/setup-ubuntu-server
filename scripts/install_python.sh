#!/bin/bash
# install_python.sh - Python environment setup with pyenv

set -e

source ./scripts/utils.sh
source .env

# Install pyenv dependencies
print_message "Installing pyenv dependencies..."
sudo apt install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    git

# Install pyenv
print_message "Installing pyenv..."
curl https://pyenv.run | bash
check_status "Pyenv installation"

# Add pyenv to bash profile (temporary until zsh is set up)
cat << 'EOF' >> ~/.bashrc

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF

# Load pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Install Python versions
for version in ${PYTHON_VERSIONS}; do
    print_message "Installing Python ${version}..."
    pyenv install ${version}
    check_status "Python ${version} installation"
done

# Set global Python version
print_message "Setting Python ${PYTHON_DEFAULT} as global..."
pyenv global ${PYTHON_DEFAULT}
check_status "Python global version setup"

# Install Python packages
print_message "Installing Python packages..."
pip install --upgrade pip
pip install ${PYTHON_PACKAGES}
check_status "Python packages installation"
