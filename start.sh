#!/bin/sh
set -e

# Use defaults if not set (backward compatible)
PUID=${PUID:-99}
PGID=${PGID:-100}
UMASK=${UMASK:-002}

echo "🔄 Starting OrpheusMoreBetter..."
echo "📋 User Configuration: PUID=${PUID} PGID=${PGID} UMASK=${UMASK}"

# Validate PUID/PGID
if [ "${PUID}" -eq 0 ] 2>/dev/null; then
    echo "⚠️  WARNING: Running as root (PUID=0) is not recommended!"
    sleep 2
fi

# Create group if it doesn't exist
if ! getent group ${PGID} > /dev/null 2>&1; then
    echo "Creating group with GID ${PGID}"
    addgroup -g ${PGID} appgroup || {
        echo "❌ Failed to create group with GID ${PGID}"
        exit 1
    }
fi

GROUP_NAME=$(getent group ${PGID} | cut -d: -f1)

# Create user if it doesn't exist
if ! getent passwd ${PUID} > /dev/null 2>&1; then
    echo "Creating user with UID ${PUID}"
    adduser -D -u ${PUID} -G ${GROUP_NAME} -h /config appuser || {
        echo "❌ Failed to create user with UID ${PUID}"
        exit 1
    }
fi

# Ensure directories exist
mkdir -p /config /data /output /torrents

# Check if config exists, provide helpful message if not
if [ ! -f /config/.orpheusmorebetter/config ]; then
    echo "ℹ️  Config file not found. It will be created on first run."
    echo "   Please edit /config/.orpheusmorebetter/config with your credentials."
fi

# Set ownership of application directories
echo "Setting permissions..."
chown -R ${PUID}:${PGID} /config /output /torrents /app 2>/dev/null || true

# Set umask for the session
umask ${UMASK}

# Drop privileges and run application
echo "✅ Starting application as UID ${PUID}, GID ${PGID}"
exec su-exec ${PUID}:${PGID} /app/orpheusmorebetter "$@"
