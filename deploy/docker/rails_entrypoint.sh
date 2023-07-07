#!/bin/bash
set -e

export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true

# Build assets during first run
if [ ! -d "public/vite" ]; then
  bundle exec rails assets:precompile
fi

# Remove any pre-existing server.pid.
rm -f /myapp/tmp/pids/server.pid

# Run Dockerfile CMD command
exec "$@"
