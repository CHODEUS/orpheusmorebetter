#!/bin/sh
set -e

cd /app

echo "🔄 Starting OrpheusMoreBetter..."

# Ensure config directory exists
mkdir -p /config

# If config is owned by the wrong user, correct it (orpheus:orpheus / 99:99).
# Ignore failures if container not privileged to change ownership.
# This will change ownership of a host-mounted volume if the container runs as root.
chown -R orpheus:orpheus /config 2>/dev/null || true

# Drop privileges and exec the script directly (uses the script's shebang).
exec su-exec orpheus /app/orpheusmorebetter "$@"
