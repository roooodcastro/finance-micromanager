#!/bin/bash
set -e

# Create new or migrate existing database
bundle exec rails db:prepare

# Remove any pre-existing server.pid.
rm -f /finance_micromanager/tmp/pids/server.pid

# Run Dockerfile CMD command
exec "$@"
