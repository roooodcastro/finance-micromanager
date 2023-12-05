# frozen_string_literal: true

class SettingsController < AbstractAuthenticatedController
  def show
    render inertia: 'settings/Show', props: camelize_props(user: current_user.as_json, skip_container: true)
  end

  def update
    user = current_user
    if user.update(user_params)
      redirect_to profile_path, success: t('.success')
    else
      flash[:error] = t('.error')
      render inertia: 'settings/Show', props: camelize_props(user: user.as_json, edit_mode: true, skip_container: true)
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :default_profile_id)
  end
end
