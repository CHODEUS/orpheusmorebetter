#!/bin/sh
set -e

cd /app

echo "🔄 Starting OrpheusMoreBetter..."

# Ensure config directory exists
mkdir -p /config

# If config is owned by the wrong user, correct it (99:100).
# Ignore failures if container not privileged to change ownership.
# This will change ownership of a host-mounted volume if the container runs as root.
chown -R 99:100 /config 2>/dev/null || true

# Create default config if missing (keeps original behavior)
if [ ! -f /config/config.yaml ]; then
    echo "📝 No config.yaml found in /config — creating default..."
    if [ -f /app/config.example.yaml ]; then
        cp /app/config.example.yaml /config/config.yaml
    elif [ -f /app/config.yaml ]; then
        cp /app/config.yaml /config/config.yaml
    else
        echo "# Default OrpheusMoreBetter config" > /config/config.yaml
        echo "log_level: INFO" >> /config/config.yaml
        echo "api_key: ''" >> /config/config.yaml
        echo "server_url: 'https://example.com'" >> /config/config.yaml
    fi
fi

# Print version info
if [ -d .git ]; then
    GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
else
    GIT_COMMIT="unknown"
    GIT_BRANCH="unknown"
fi

echo "🔹 Git branch: ${GIT_BRANCH}"
echo "🔹 Git commit: ${GIT_COMMIT}"
echo "${GIT_BRANCH}" > /app/branch.txt
echo "${GIT_COMMIT}" > /app/version.txt

# Drop privileges and exec the app as uid 99 (orpheus).
# Use su-exec (lightweight) to switch user.
# If su-exec is not available, you can replace with "su -s /bin/sh orpheus -c ..." or gosu.
exec su-exec orpheus python -m orpheusmorebetter "$@"
