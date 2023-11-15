# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    def respond_with(*); end

    def show
      super

      redirect_to login_path
    end

    def new
      super

      pre_populated_email = resource.pending_reconfirmation? ? resource.unconfirmed_email : resource.email
      render inertia: 'users/confirmations/New', props: { pre_populated_email: }
    end
  end
end
