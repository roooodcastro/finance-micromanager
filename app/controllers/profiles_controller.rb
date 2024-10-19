# frozen_string_literal: true

class ProfilesController < AbstractAuthenticatedController
  before_action :set_profile, only: %i[show update destroy reenable]

  def index
    respond_to do |format|
      format.html { render inertia: 'profiles/Index' }
      format.json do
        initial_relation = Profile
                           .left_joins(:profile_shares)
                           .where(profile_shares: { user: current_user })
                           .or(current_user.profiles)
                           .includes(:wallets, :default_wallet, :user, :latest_reconciliation)
        profiles         = ProfileSearch.new(initial_relation, search_params).search

        render json: camelize_props(profiles: profiles.map { |profile| profile.as_json(include_wallets: true) })
      end
    end
  end

  def show
    respond_to do |format|
      format.html { render inertia: 'profiles/Show' }
      format.json { render json: @profile.as_json(include_wallets: true) }
    end
  end

  def create
    profile = current_user.profiles.new(profile_params)

    if profile.save
      render json: camelize_props(message: t('.success', name: profile.display_name))
    else
      render json:   camelize_props(message: t('.error', error: profile.error_messages)),
             status: :unprocessable_entity
    end
  end

  def update
    if @profile.update(profile_params)
      render json: camelize_props(message: t('.success', name: @profile.name))
    else
      render json: camelize_props(
        message: t('.error', name: @profile.display_name, error: @profile.error_messages)
      ), status: :unprocessable_entity
    end
  end

  def destroy
    @profile.disable!

    render json: camelize_props(message: t('.success', name: @profile.display_name))
  end

  def reenable
    @profile.enable!

    render json: camelize_props(message: t('.success', name: @profile.display_name))
  end

  private

  def set_profile
    @profile = current_user.find_available_profile(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:currency, :name, :default_wallet_id)
  end

  def search_params
    params.permit(%i[show_disabled]).to_h.symbolize_keys
  end
end
