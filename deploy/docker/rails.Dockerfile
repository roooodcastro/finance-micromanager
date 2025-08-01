# syntax=docker/dockerfile:1.7-labs

ARG RUBY_VERSION=3.4.5

FROM ruby:$RUBY_VERSION-slim AS builder

# Install build dependencies
RUN apt update -qq &&\
    apt install -y build-essential libpq-dev libyaml-dev ca-certificates curl gnupg lsb-release &&\
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg &&\
    export NODE_MAJOR=21 &&\
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list &&\
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' &&\
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg &&\
    apt-get update &&\
    apt install -y nodejs postgresql-client &&\
    npm install -g yarn

# Copy setup files and install gems and yarn packages
WORKDIR /finance_micromanager

ENV RAILS_SERVE_STATIC_FILES="true" \
    RAILS_ENV="production"

COPY Gemfile Gemfile.lock ./
COPY vendor/cache ./vendor/cache

# Configure bundler and install gems from local cache
RUN bundle config set deployment true && \
    bundle config set without 'development test' && \
    bundle install --local

COPY package.json yarn.lock .env.docker_development /finance_micromanager/
RUN yarn install --frozen-lockfile --prod --network-timeout 300000 && yarn cache clean

# Copy application code
COPY . /finance_micromanager

# Compile assets
RUN mv .env.docker_development .env.production.local && \
    SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile --trace && \
    rm -rf /finance_micromanager/node_modules

FROM ruby:$RUBY_VERSION-slim AS app

# Install runtime dependencies
RUN apt update -qq &&\
    apt upgrade -y --no-install-recommends &&\
    apt install -y --no-install-recommends ca-certificates curl gnupg lsb-release libjemalloc2 &&\
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' &&\
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg &&\
    apt-get update &&\
    apt install -y postgresql-client

WORKDIR /finance_micromanager

ENV LD_PRELOAD="libjemalloc.so.2" \
    MALLOC_CONF="background_thread:true,metadata_thp:auto,dirty_decay_ms:5000,muzzy_decay_ms:5000,narenas:2" \
    RUBY_YJIT_ENABLE="1"

# Copy relevant files from builder stage
COPY --from=builder --exclude=vendor/cache /finance_micromanager /finance_micromanager
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Configure entrypoint
COPY deploy/docker/rails_entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh && date -u '+%Y%m%d%H%M%S' > DEPLOY_TIMESTAMP

# Precompile bootsnap code for faster boot times
RUN rm -rf /finance_micromanager/tmp/cache
RUN bundle exec bootsnap precompile --gemfile app/ lib/

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
