# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    def new
      build_resource

      render inertia: 'users/registrations/New', props: { user: resource }
    end

    def create # rubocop:disable Metrics/AbcSize
      build_resource(sign_up_params)

      resource.save

      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          redirect_to location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          redirect_to location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords(resource)
        set_minimum_password_length

        render inertia: 'users/registrations/New', props: {
          errors: format_error_messages(resource),
          user: resource
        }
      end
    end

    private

    def signed_in_root_path(*)
      dashboard_path
    end

    # def after_inactive_sign_up_path_for(resource)
    # end
  end
end
