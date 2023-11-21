FROM ruby:3.2.2

# Install dependencies
RUN apt update -qq &&\
    apt install -y ca-certificates curl gnupg &&\
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg &&\
    export NODE_MAJOR=20 &&\
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list &&\
    apt-get update &&\
    apt install -y nodejs postgresql-client &&\
    npm install -g yarn

# Copy setup files and install gems and yarn packages
WORKDIR /finance_micromanager
COPY Gemfile Gemfile.lock package.json yarn.lock .env.docker_development /finance_micromanager/
RUN yarn install --prod --network-timeout 300000
RUN MAKE="make --jobs 4" bundle install --jobs 4

# Copy application and configure entrypoint
COPY . /finance_micromanager
COPY deploy/docker/rails_entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh && \
    mv .env.docker_development .env.production.local && \
    date -u '+%d%m%Y%H%M%S' > DEPLOY_TIMESTAMP
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
