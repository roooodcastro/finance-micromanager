#!/bin/bash
set -e

export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true

# Create new or migrate existing database
bundle exec rails db:prepare

# Remove any pre-existing server.pid.
rm -f /finance_micromanager/tmp/pids/server.pid

# Run Dockerfile CMD command
exec "$@"
