#!/bin/bash
set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/pastioke/onifast/main"
BIN_DIR="/usr/local/bin"
SERVICE_DIR="/etc/systemd/system"
WORKDIR="/home/root/onifast"
TMP_DIR=$(mktemp -d) # Temporary directory for downloads

# Clean up temp dir on exit
trap 'rm -rf "$TMP_DIR"' EXIT

# List of binaries and their paths in your repo
BINARIES=(
    "onifast-panel"
    "cmd/onifast-s3/onifast-s3"
    "cmd/onifast-proxy/onifast-proxy"
    "cmd/onifast-dns/onifast-dns"
    "cmd/onifast-web/onifast-web"
    "cmd/onifast-mail/onifast-mail"
    "cmd/onifast-ftp/onifast-ftp"
)

# List of systemd services
SERVICES=(
    "onifast-panel.service"
    "onifast-s3.service"
    "onifast-proxy.service"
    "onifast-dns.service"
    "onifast-web.service"
    "onifast-mail.service"
    "onifast-ftp.service"
)

echo "--- Phase 1: Downloading New Files ---"

# 1. Download Binaries to Temp
for bin_path in "${BINARIES[@]}"; do
    filename=$(basename "$bin_path")
    echo "Downloading $filename..."
    curl -fsSL "$REPO_URL/$bin_path" -o "$TMP_DIR/$filename" || { echo "Failed to download $filename"; exit 1; }
    chmod +x "$TMP_DIR/$filename"
done

# 2. Download Service Files to Temp
for service in "${SERVICES[@]}"; do
    echo "Downloading $service..."
    curl -fsSL "$REPO_URL/$service" -o "$TMP_DIR/$service" || { echo "Failed to download $service"; exit 1; }
done

echo "--- Phase 2: Stopping and Cleaning Old Services ---"

# 3. Stop and remove existing services/binaries
for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "Stopping $service..."
        systemctl stop "$service"
    fi
    
    if [ -f "$SERVICE_DIR/$service" ]; then
        echo "Removing old service file $service..."
        systemctl disable "$service" --quiet || true
        rm -f "$SERVICE_DIR/$service"
    fi
done

for bin_path in "${BINARIES[@]}"; do
    filename=$(basename "$bin_path")
    if [ -f "$BIN_DIR/$filename" ]; then
        echo "Removing old binary $filename..."
        rm -f "$BIN_DIR/$filename"
    fi
done

# Reload daemon to clear out the removed services
systemctl daemon-reload

echo "--- Phase 3: Installing New Files ---"

# 4. Create working directory
mkdir -p "$WORKDIR/logs"
chmod 755 "$WORKDIR"

# 5. Move Binaries from Temp to Bin Dir
for bin_path in "${BINARIES[@]}"; do
    filename=$(basename "$bin_path")
    mv "$TMP_DIR/$filename" "$BIN_DIR/$filename"
done

# 6. Move Service Files from Temp to Service Dir
for service in "${SERVICES[@]}"; do
    mv "$TMP_DIR/$service" "$SERVICE_DIR/$service"
done

echo "--- Phase 4: Finalizing Installation ---"

# 7. Reload systemd and start services
systemctl daemon-reload

for service in "${SERVICES[@]}"; do
    echo "Starting and enabling $service..."
    systemctl enable "$service"
    systemctl start "$service"
done

echo "--- Installation Complete ---"
echo "Working directory is: $WORKDIR"
echo "Check status with: systemctl status onifast-*"