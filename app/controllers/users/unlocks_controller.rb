# frozen_string_literal: true

module Users
  class UnlocksController < Devise::UnlocksController
    def respond_with(*); end

    def new
      super

      render inertia: 'users/unlocks/New'
    end
  end
end
