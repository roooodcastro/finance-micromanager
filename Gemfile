# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.2.0', '< 3.4.0'

# Default Rails gems
gem 'pg', '~> 1.1'
gem 'puma', '~> 6.0'
gem 'rails', '~> 7.1.0'
gem 'redis', '~> 4.0'

# Frontend
gem 'i18n-js'
gem 'importmap-rails'
gem 'inertia_rails'
gem 'jbuilder'
gem 'js_from_routes'
gem 'sprockets-rails'
gem 'turbo-rails'
gem 'vite_rails'

gem 'connection_pool'
gem 'devise'
gem 'dotenv-rails'
gem 'money-rails'
gem 'newrelic_rpm'
gem 'pagy'
gem 'pry'
gem 'roo'
gem 'roo-xls'
gem 'sidekiq'
gem 'sidekiq-scheduler'

gem 'bootsnap', require: false
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'sassc-rails'

group :test do
  gem 'simplecov', require: false
  gem 'simplecov_json_formatter', require: false
end

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'pry-rails'
  gem 'rspec'
  gem 'rspec-rails'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman', require: false
  gem 'listen'
  gem 'overcommit', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'spring'
  gem 'web-console'
end
