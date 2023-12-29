FROM ruby:3.3

# Install dependencies
RUN apt update -qq &&\
    apt install -y ca-certificates curl gnupg lsb-release &&\
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg &&\
    export NODE_MAJOR=20 &&\
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list &&\
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' &&\
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg &&\
    apt-get update &&\
    apt install -y nodejs postgresql-client &&\
    npm install -g yarn

# Copy setup files and install gems and yarn packages
WORKDIR /finance_micromanager
COPY package.json yarn.lock .env.docker_development /finance_micromanager/
RUN yarn install --frozen-lockfile --prod --network-timeout 300000 && yarn cache clean
COPY Gemfile Gemfile.lock /finance_micromanager/
COPY vendor/cache /finance_micromanager/vendor/cache
RUN bundle config set deployment true && bundle install --local

# Copy application code
COPY . /finance_micromanager

# Compile assets
RUN bundle exec rails assets:precompile

# Configure entrypoint
COPY deploy/docker/rails_entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh && \
    mv .env.docker_development .env.production.local && \
    date -u '+%d%m%Y%H%M%S' > DEPLOY_TIMESTAMP
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
