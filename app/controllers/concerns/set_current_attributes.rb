# frozen_string_literal: true

module SetCurrentAttributes
  extend ActiveSupport::Concern

  included do
    before_action :set_current_attributes
  end

  def set_current_attributes
    # Current.locale is set in Localizeable concern
    Current.profile = current_profile if user_signed_in?
    Current.user    = current_user if user_signed_in?

    CurrentDateRange.start_date = params[:start_date]
    CurrentDateRange.end_date   = params[:end_date]
  end

  def current_profile
    profile_id = session[:current_profile_id] || current_user.default_profile_id
    current_user.find_available_profile(profile_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
