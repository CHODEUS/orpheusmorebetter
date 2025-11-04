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

# Drop privileges and exec the script directly (uses the script's shebang).
exec su-exec orpheus /app/orpheusmorebetter "$@"
