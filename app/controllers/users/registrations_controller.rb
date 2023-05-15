# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    def respond_with(*); end

    def new
      super

      render inertia: 'users/registrations/New'
    end
  end
end
