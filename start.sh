#!/bin/sh
set -e

# Clear previous logs
> /proc/1/fd/1 2>/dev/null || true
> /proc/1/fd/2 2>/dev/null || true

# Use defaults if not set (backward compatible)
PUID=${PUID:-99}
PGID=${PGID:-100}
UMASK=${UMASK:-002}

# Function to log with timestamp directly to stderr (unbuffered)
log() {
    printf '%s - %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >&2
}

log "🔄 Starting OrpheusMoreBetter..."
log "📋 User Configuration: PUID=${PUID} PGID=${PGID} UMASK=${UMASK}"

# Validate PUID/PGID
if [ "${PUID}" -eq 0 ] 2>/dev/null; then
    log "⚠️  WARNING: Running as root (PUID=0) is not recommended!"
    sleep 2
fi

# Create group if it doesn't exist
if ! getent group ${PGID} > /dev/null 2>&1; then
    log "Creating group with GID ${PGID}"
    addgroup -g ${PGID} appgroup || {
        log "❌ Failed to create group with GID ${PGID}"
        exit 1
    }
fi

GROUP_NAME=$(getent group ${PGID} | cut -d: -f1)

# Create user if it doesn't exist
if ! getent passwd ${PUID} > /dev/null 2>&1; then
    log "Creating user with UID ${PUID}"
    adduser -D -u ${PUID} -G ${GROUP_NAME} -h /config appuser || {
        log "❌ Failed to create user with UID ${PUID}"
        exit 1
    }
fi

# Ensure directories exist
mkdir -p /config /data /output /torrents

# Check if config exists, provide helpful message if not
if [ ! -f /config/.orpheusmorebetter/config ]; then
    log "ℹ️  Config file not found. It will be created on first run."
    log "   Please edit /config/.orpheusmorebetter/config with your credentials."
fi

# Set ownership of application directories
log "Setting permissions..."
chown -R ${PUID}:${PGID} /config /output /torrents /app 2>/dev/null || true

# Set umask for the session
umask ${UMASK}

# Drop privileges and run application with unbuffered Python output
log "✅ Starting application as UID ${PUID}, GID ${PGID}"

exec su-exec ${PUID}:${PGID} env HOME=/config python3 -u /app/orpheusmorebetter "$@"
