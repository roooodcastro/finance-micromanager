# frozen_string_literal: true

class ProfilesController < AbstractAuthenticatedController
  before_action :set_profile, only: %i[show edit update destroy]

  def index
    profiles = current_user.available_profiles
    props    = camelize_props(
      profiles:        profiles.as_json,
      current_profile: Current.profile.as_json
    )

    respond_to do |format|
      format.html { render inertia: 'profiles/Index', props: props }
      format.json { render json: props }
    end
  end

  def show
    render inertia: 'profiles/Show'
  end

  def new
    profile = Profile.new

    render inertia: 'profiles/New', props: { profile: camelize_props(profile.as_json) }
  end

  def edit
    render inertia: 'profiles/Edit', props: { profile: camelize_props(@profile.as_json) }
  end

  def create
    profile = current_user.profiles.new(profile_params)

    return redirect_to profiles_path, success: t('.success') if profile.save

    flash.now[:error] = t('.error', name: profile.display_name, error: profile.errors.full_messages.join(', '))
    render inertia: 'profiles/New', props: { profile: camelize_props(profile.as_json) }
  end

  def update
    updated = @profile.update(profile_params)

    return redirect_to profiles_path, success: t('.success', name: @profile.display_name) if updated

    flash.now[:error] = t('.error', name: @profile.display_name, error: @profile.errors.full_messages.join(', '))
    render inertia: 'profiles/Edit', props: { profile: camelize_props(@profile.as_json) }
  end

  def destroy
    @profile.disabled!

    render json: camelize_props(profile_id: @profile.id, message: t('.success', name: @profile.display_name))
  end

  private

  def set_profile
    @profile = current_user.find_available_profile(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:currency, :name, :default_wallet_id)
  end
end
