# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    def respond_with(*); end

    def show
      super

      render inertia: 'users/confirmations/Show'
    end

    def new
      super

      render inertia: 'users/confirmations/New'
    end
  end
end
