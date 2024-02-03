# frozen_string_literal: true

class ProfilesController < AbstractAuthenticatedController
  before_action :set_profile, only: %i[show update destroy]

  def index
    profiles = current_user.available_profiles
    props    = camelize_props(
      profiles:        profiles.map { |profile| profile.as_json(include_wallets: true) },
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

  def create
    profile = current_user.profiles.new(profile_params)

    if profile.save
      render json: camelize_props(message: t('.success', name: profile.display_name))
    else
      render json:   camelize_props(message: t('.error', error: profile.errors.full_messages.join(', '))),
             status: :unprocessable_entity
    end
  end

  def update
    if @profile.update(profile_params)
      render json: camelize_props(message: t('.success', name: @profile.name))
    else
      render json: camelize_props(
        message: t('.error', name: @profile.display_name, error: @profile.errors.full_messages.join(', '))
      ), status: :unprocessable_entity
    end
  end

  def destroy
    @profile.disabled!

    render json: camelize_props(message: t('.success', name: @profile.display_name))
  end

  private

  def set_profile
    @profile = current_user.find_available_profile(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:currency, :name, :default_wallet_id)
  end
end
