#!/bin/bash

# Configuration
REPO_URL="https://raw.githubusercontent.com/pastioke/onifast/main"
BIN_DIR="/usr/local/bin"
SERVICE_DIR="/etc/systemd/system"
WORKDIR="/home/root/onifast"

# List of binaries and their paths in your repo
BINARIES=(
    "onifast-panel"
    "cmd/onifast-s3/onifast-s3"
    "cmd/onifast-relay/onifast-relay"
    "cmd/onifast-dns/onifast-dns"
    "cmd/onifast-web/onifast-web"
    "cmd/onifast-mail/onifast-mail"
    "cmd/onifast-ftp/onifast-ftp"
)

# List of systemd services
SERVICES=(
    "onifast-panel.service"
    "onifast-s3.service"
    "onifast-relay.service"
    "onifast-dns.service"
    "onifast-web.service"
    "onifast-mail.service"
    "onifast-ftp.service"
)

echo "--- Starting Onifast Suite Installation ---"

# 1. Create working directory and logs directory
echo "Creating working directory $WORKDIR..."
mkdir -p "$WORKDIR/logs"
chmod 755 "$WORKDIR"

# 2. Download and Install Binaries
for bin_path in "${BINARIES[@]}"; do
    filename=$(basename "$bin_path")
    echo "Downloading $filename..."
    curl -fsSL "$REPO_URL/$bin_path" -o "$BIN_DIR/$filename" || { echo "Failed to download $filename"; exit 1; }
    chmod +x "$BIN_DIR/$filename"
done

# 3. Download and Install Systemd Services
for service in "${SERVICES[@]}"; do
    echo "Installing $service..."
    curl -fsSL "$REPO_URL/$service" -o "$SERVICE_DIR/$service" || { echo "Failed to download $service"; exit 1; }
done

# 4. Reload systemd and enable/start services
echo "Reloading systemd daemon..."
systemctl daemon-reload

for service in "${SERVICES[@]}"; do
    echo "Configuring $service..."
    systemctl enable "$service"
    systemctl start "$service"
    echo "Started and enabled $service"
done

echo "--- Installation Complete ---"
echo "Working directory is: $WORKDIR"
echo "All Onifast services have been started and enabled."
echo "Check status with: systemctl status onifast-*"