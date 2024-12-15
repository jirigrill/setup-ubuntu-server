#!/bin/bash
# install_zsh.sh - ZSH setup with Oh My Zsh

set -e

source ./scripts/utils.sh
source .env

# Install ZSH if not already installed
print_message "Installing ZSH..."
sudo apt install -y zsh
check_status "ZSH installation"

# Install required packages for themes and plugins
print_message "Installing additional requirements..."
sudo apt install -y \
    fonts-powerline \
    autojump \
    fzf \
    git-flow
check_status "Additional packages"

# Install Oh My Zsh
print_message "Installing Oh My Zsh..."
if [ -d ~/.oh-my-zsh ]; then
    print_warning "Oh My Zsh is already installed, skipping installation..."
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
check_status "Oh My Zsh installation"

# Install popular plugins
print_message "Installing ZSH plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
check_status "Plugin installation"

# Configure ZSH
print_message "Configuring ZSH..."
cat > ~/.zshrc << 'EOF'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="agnoster"

# Set plugins
plugins=(
    git
    docker
    docker-compose
    python
    pip
    virtualenv
    node
    npm
    sudo
    autojump
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    command-not-found
    history
    dirhistory
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='vim'

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='vim'
fi

# System administration paths
export PATH=$PATH:/usr/sbin:/sbin

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Docker aliases
alias d='docker'
alias dc='docker compose'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dcl='docker compose logs -f'
alias dps='docker ps'
alias dex='docker exec -it'

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline'

# Python aliases
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# Directory shortcuts
alias projects='cd ~/python_projects'
alias media='cd ~/mediaserver'
alias logs='cd ~/logs'

# Autojump
. /usr/share/autojump/autojump.sh

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
EOF

# Set ZSH as default shell
print_message "Setting ZSH as default shell..."
sudo chsh -s $(which zsh) ${USERNAME}
check_status "Default shell configuration"

print_message "ZSH setup complete!"
print_message "Your shell has been configured with:"
echo "1. Oh My Zsh with agnoster theme"
echo "2. Useful plugins (autosuggestions, syntax highlighting, etc.)"
echo "3. Docker, Git, and Python aliases"
echo "4. Directory shortcuts"
echo "5. Enhanced command-line navigation with autojump and fzf"
echo ""
print_warning "Please log out and log back in for the shell change to take effect."
