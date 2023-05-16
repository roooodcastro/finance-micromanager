# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def respond_with(*); end

    def new
      super

      render inertia: 'users/sessions/New'
    end

    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      redirect_to after_sign_in_path_for(resource)
    end

    private

    def signed_in_root_path(*)
      dashboard_path
    end
  end
end
