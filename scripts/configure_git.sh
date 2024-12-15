#!/bin/bash
# configure_git.sh - Git configuration setup

set -e

source ./scripts/utils.sh
source .env

print_message "Configuring Git..."

# Prompt for Git user information
read -p "Enter your Git username: " git_username
read -p "Enter your Git email: " git_email

# Configure user settings
print_message "Setting up Git user configuration..."
git config --global user.name "${git_username}"
git config --global user.email "${git_email}"
check_status "Git user configuration"

# Configure core settings
print_message "Configuring Git core settings..."
git config --global init.defaultBranch main
git config --global core.editor vim
git config --global core.autocrlf input
git config --global core.fileMode true
git config --global core.ignorecase false
check_status "Git core settings"

# Configure colors
print_message "Configuring Git colors..."
git config --global color.ui true
git config --global color.status auto
git config --global color.branch auto
check_status "Git color settings"

# Configure pull strategy
print_message "Configuring Git pull settings..."
git config --global pull.rebase false
check_status "Git pull settings"

# Configure helpful aliases
print_message "Setting up Git aliases..."
git config --global alias.st status
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.df diff
git config --global alias.dfs "diff --staged"
check_status "Git aliases"

# Configure diff and merge tools
print_message "Configuring diff and merge settings..."
git config --global diff.algorithm histogram
git config --global merge.conflictstyle diff3
git config --global merge.tool vimdiff
check_status "Git diff and merge settings"

# Configure helpful defaults
print_message "Setting helpful defaults..."
git config --global push.default current
git config --global fetch.prune true
git config --global help.autocorrect 20
check_status "Git defaults"

# Create global gitignore
print_message "Creating global gitignore..."
cat > ~/.gitignore_global << 'EOF'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.idea/
.vscode/
*.swp
*.swo
*~

# Python files
*.py[cod]
__pycache__/
*.so
.Python
env/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg
.python-version
.env
.venv
venv/
ENV/

# Node files
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Log files
*.log
logs/
EOF

git config --global core.excludesfile ~/.gitignore_global
check_status "Global gitignore"

print_message "Git configuration complete!"
echo ""
echo "Configured settings:"
echo "1. Username: ${git_username}"
echo "2. Email: ${git_email}"
echo "3. Default branch: main"
echo "4. Pull strategy: merge (not rebase)"
echo "5. Added useful aliases:"
echo "   - st = status"
echo "   - ci = commit"
echo "   - co = checkout"
echo "   - br = branch"
echo "   - lg = pretty log with graph"
echo "   - df = diff"
echo "   - dfs = diff staged"
echo "6. Created global gitignore file"
echo ""
echo "To verify settings:"
echo "git config --list"
echo ""
echo "To use aliases:"
echo "git st    # status"
echo "git lg    # pretty log"
echo "git dfs   # view staged changes"
