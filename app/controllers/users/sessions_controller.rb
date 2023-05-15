# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def respond_with(*); end

    def new
      super

      render inertia: 'users/sessions/New'
    end
  end
end
