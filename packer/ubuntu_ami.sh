#!/bin/bash
set -e

# Update package lists
echo "Updating package lists..."
sudo apt update -y
sudo apt upgrade -y

# Install prerequisites
echo "Installing prerequisites..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Add Docker's official GPG key
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker repository
echo "Setting up Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again with the new repository
sudo apt update -y

# Install Docker Engine
echo "Installing Docker Engine..."
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker service
echo "Enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to the docker group
echo "Adding ubuntu user to docker group..."
sudo usermod -aG docker ubuntu

# Verify Docker installation
echo "Verifying Docker installation..."
sudo docker --version
sudo docker info

# Install Docker Compose (optional but recommended)
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
docker-compose --version

echo "Docker installation completed successfully!"
