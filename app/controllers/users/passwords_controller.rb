# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    def respond_with(*); end

    def new
      super

      render inertia: 'users/passwords/New'
    end
  end
end
