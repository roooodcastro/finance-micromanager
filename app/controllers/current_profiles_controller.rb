# frozen_string_literal: true

class CurrentProfilesController < AbstractAuthenticatedController
  def create
    profile = current_user.find_available_profile(params[:profile_id])

    session[:current_profile_id] = profile.id
    render json: { profile: profile.as_json }
  rescue ActiveRecord::RecordNotFound
    render json: { error: t('.error') }
  end
end
