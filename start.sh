#!/bin/sh
set -e

# Use defaults if not set (backward compatible)
PUID=${PUID:-99}
PGID=${PGID:-100}
UMASK=${UMASK:-002}

echo "🔄 Starting OrpheusMoreBetter..."
echo "📋 User Configuration: PUID=${PUID} PGID=${PGID} UMASK=${UMASK}"

# Create group if it doesn't exist
if ! getent group ${PGID} > /dev/null 2>&1; then
    echo "Creating group with GID ${PGID}"
    addgroup -g ${PGID} appgroup
fi

GROUP_NAME=$(getent group ${PGID} | cut -d: -f1)

# Create user if it doesn't exist
if ! getent passwd ${PUID} > /dev/null 2>&1; then
    echo "Creating user with UID ${PUID}"
    adduser -D -u ${PUID} -G ${GROUP_NAME} -h /config appuser
fi

# Ensure directories exist
mkdir -p /config /data /output /torrents

# Set ownership of application directories
echo "Setting permissions..."
chown -R ${PUID}:${PGID} /config /data /output /torrents /app 2>/dev/null || true

# Set umask for the session
umask ${UMASK}

# Drop privileges and run application
echo "Starting application as UID ${PUID}, GID ${PGID}"
exec su-exec ${PUID}:${PGID} /app/orpheusmorebetter "$@"
