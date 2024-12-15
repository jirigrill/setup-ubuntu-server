#!/bin/bash
# install_docker.sh - Docker and Docker Compose installation

set -e

source ./scripts/utils.sh
source .env

# Install Docker
print_message "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
check_status "Docker installation"

# Configure Docker daemon
print_message "Configuring Docker daemon..."
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
check_status "Docker service"

# Add current user to docker group (now that Docker is installed)
print_message "Adding user to docker group..."
sudo usermod -aG docker ${USERNAME}
check_status "Docker group modification"

# Install Docker Compose
print_message "Installing Docker Compose..."
if [ "$DOCKER_COMPOSE_VERSION" = "latest" ]; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
else
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname-s)-$(uname -m)" -o /usr/local/bin/docker-compose
fi
sudo chmod +x /usr/local/bin/docker-compose
check_status "Docker Compose installation"
