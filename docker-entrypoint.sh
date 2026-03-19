#!/bin/sh
set -e

# Fix ownership of the persistent data volume so the node user (uid 1000)
# can read/write config, sessions, and credentials on fly.io volume mounts.
# This runs as root; gosu then drops privileges before exec.
if [ -d /data ]; then
    chown -R 1000:1000 /data 2>/dev/null || true
fi

# Disable Docker sandbox — Docker is not available on fly.io.
# This runs as root before dropping to node so it can write to /data if needed.
# gosu node ensures the config write happens as the correct owner.
gosu node openclaw config set agents.defaults.sandbox.mode off 2>/dev/null || true

# Drop from root to the node user and exec the real command.
exec gosu node "$@"
