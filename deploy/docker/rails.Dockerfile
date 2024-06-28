ARG RUBY_VERSION=3.3.3

FROM ruby:$RUBY_VERSION as builder

# Install build dependencies
RUN apt update -qq &&\
    apt install -y ca-certificates curl gnupg lsb-release &&\
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

FROM ruby:3.3.3 as app

# Install runtime dependencies
RUN apt update -qq &&\
    apt install -y ca-certificates curl gnupg lsb-release &&\
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' &&\
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg &&\
    apt-get update &&\
    apt install -y postgresql-client

WORKDIR /finance_micromanager

# Copy relevant files from builder stage
COPY --from=builder /finance_micromanager /finance_micromanager
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Configure entrypoint
COPY deploy/docker/rails_entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh && date -u '+%d%m%Y%H%M%S' > DEPLOY_TIMESTAMP
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
