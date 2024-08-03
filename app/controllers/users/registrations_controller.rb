# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    def new
      build_resource

      render inertia: 'users/registrations/New', props: { user: resource.as_json }
    end

    def create
      build_resource(sign_up_params)

      resource.save

      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :success, :signed_up
          sign_up(resource_name, resource)
          redirect_to after_sign_up_path_for(resource)
        else
          set_flash_message! :success, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          redirect_to after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords(resource)
        set_minimum_password_length

        render inertia: 'users/registrations/New', props: {
          errors: format_error_messages(resource),
          user:   resource
        }
      end
    end

    def update # rubocop:disable Metrics/AbcSize
      self.resource          = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

      resource_updated = update_resource(resource, account_update_params)
      yield resource if block_given?
      if resource_updated
        set_flash_message_for_update(resource, prev_unconfirmed_email)
        bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
        flash[:success] = t('.success')
      else
        clean_up_passwords resource
        set_minimum_password_length
        flash[:danger] = t('.error', error: resource.error_messages)
      end

      redirect_to setting_path
    end

    private

    def signed_in_root_path(*)
      dashboard_path
    end
  end
end
