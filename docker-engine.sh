#!/usr/bin/env bash

set -e

echo "========================================"
echo " Docker Engine Installation"
echo "========================================"

# Must be run as root or with sudo privileges
if [[ "$EUID" -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

echo
echo "[1/6] Removing conflicting packages..."

$SUDO apt remove -y \
    docker.io \
    docker-doc \
    docker-compose \
    podman-docker \
    containerd \
    runc || true

echo
echo "[2/6] Installing prerequisites..."

$SUDO apt update
$SUDO apt install -y ca-certificates curl

echo
echo "[3/6] Adding Docker's official GPG key..."

$SUDO install -m 0755 -d /etc/apt/keyrings

$SUDO curl -fsSL \
    https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

$SUDO chmod a+r /etc/apt/keyrings/docker.asc

echo
echo "[4/6] Adding Docker's official repository..."

# Read distribution information
source /etc/os-release

if [[ "$ID" != "ubuntu" && "$ID_LIKE" != *"debian"* ]]; then
    echo
    echo "ERROR: This script is intended for Ubuntu/Debian."
    echo "Detected distribution: $PRETTY_NAME"
    exit 1
fi

# Determine repository path
if [[ "$ID" == "ubuntu" ]]; then
    DOCKER_REPO="ubuntu"
    DOCKER_CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
else
    DOCKER_REPO="debian"
    DOCKER_CODENAME="$VERSION_CODENAME"
fi

echo "Distribution: $PRETTY_NAME"
echo "Repository:   $DOCKER_REPO"
echo "Codename:     $DOCKER_CODENAME"

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DOCKER_REPO \
    $DOCKER_CODENAME stable" | \
    $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

echo
echo "[5/6] Installing Docker Engine..."

$SUDO apt update

$SUDO apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo
echo "[6/6] Starting Docker..."

$SUDO systemctl enable --now docker

echo
echo "========================================"
echo " Configuring Docker permissions"
echo "========================================"

CURRENT_USER="${SUDO_USER:-$USER}"

if [[ "$CURRENT_USER" != "root" ]]; then
    $SUDO usermod -aG docker "$CURRENT_USER"
    echo
    echo "Added '$CURRENT_USER' to the docker group."
fi

echo
echo "========================================"
echo " Docker installation complete!"
echo "========================================"

echo
echo "Docker version:"
docker --version || $SUDO docker --version

echo
echo "Docker service:"
$SUDO systemctl --no-pager --full status docker || true

echo
echo "========================================"
echo " IMPORTANT"
echo "========================================"

if [[ "$CURRENT_USER" != "root" ]]; then
    echo "Log out and log back in for Docker group"
    echo "permissions to take effect."
    echo
    echo "Or run:"
    echo
    echo "    newgrp docker"
fi

echo
echo "Then test Docker with:"
echo
echo "    docker run hello-world"
echo
echo "========================================"