# frozen_string_literal: true

%w[
  .ruby-version
  tmp/restart.txt
  tmp/caching-dev.txt
  app/services
].each { |path| Spring.watch(path) }
