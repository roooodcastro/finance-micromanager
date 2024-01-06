# frozen_string_literal: true

class SettingsController < AbstractAuthenticatedController
  def show
    props = camelize_props(user: current_user.as_json)

    respond_to do |format|
      format.html { render inertia: 'settings/Show', props: props }
      format.json { render json: props }
    end
  end

  def update
    if current_user.update(user_params)
      I18n.locale = current_user.locale
      render json: { message: t('.success') }
    else
      render json: { message: t('.error') }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :default_profile_id, :locale)
  end
end
