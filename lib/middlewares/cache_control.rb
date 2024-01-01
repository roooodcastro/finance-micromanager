# frozen_string_literal: true

module Middlewares
  class CacheControl < ActionDispatch::Static
    def call(env)
      status, headers, response = super

      headers['Cache-Control'] = 'private, max-age=0, must-revalidate' if status.in?(400..499)

      [status, headers, response]
    end
  end
end
