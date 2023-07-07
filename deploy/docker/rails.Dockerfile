FROM ruby:3.2.2

# Install dependencies
RUN apt update -qq &&\
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - &&\
    apt install -y nodejs postgresql-client &&\
    npm install -g yarn

# Copy setup files and install gems and yarn packages
WORKDIR /finance_micromanager
COPY Gemfile Gemfile.lock package.json yarn.lock .env.docker_development.local /finance_micromanager/
RUN bundle install && yarn install --prod

# Copy application and configure entrypoint
COPY . /finance_micromanager
COPY deploy/docker/rails_entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh && \
    mv .env.docker_development.local .env.production.local
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
