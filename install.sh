#!/bin/bash

# Configuration
REPO_URL="https://raw.githubusercontent.com/pastioke/onifast/main"
BIN_DIR="/usr/local/bin"
SERVICE_DIR="/etc/systemd/system"

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

# 1. Download and Install Binaries
for bin_path in "${BINARIES[@]}"; do
    filename=$(basename "$bin_path")
    echo "Downloading $filename..."
    curl -fsSL "$REPO_URL/$bin_path" -o "$BIN_DIR/$filename"
    chmod +x "$BIN_DIR/$filename"
done

# 2. Download and Install Systemd Services
for service in "${SERVICES[@]}"; do
    echo "Installing $service..."
    curl -fsSL "$REPO_URL/$service" -o "$SERVICE_DIR/$service"
done

# 3. Reload systemd and enable services
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Note: We don't 'start' them automatically here in case config is needed,
# but we enable them to run on boot.
for service in "${SERVICES[@]}"; do
    systemctl enable "$service"
    echo "Enabled $service"
done

echo "--- Installation Complete ---"
echo "You can start the panel with: systemctl start onifast-panel"