#!/bin/bash
set -e

export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true

# Run migrations during first run
bundle exec rails db:migrate

# Remove any pre-existing server.pid.
rm -f /myapp/tmp/pids/server.pid

# Run Dockerfile CMD command
exec "$@"
