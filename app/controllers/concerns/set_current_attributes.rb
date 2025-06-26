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

    CurrentDateRange.start_date = Time.zone.parse(current_start_date)
    CurrentDateRange.end_date   = Time.zone.parse(current_end_date)
  end

  def current_profile
    profile_id = session[:current_profile_id] || current_user.default_profile_id
    current_user.find_available_profile(profile_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def current_start_date
    start_date_from_params = params[:update_date_range].to_b ? params[:start_date] : nil
    # binding.pry if start_date_from_params
    session[:start_date]   = start_date_from_params || session[:start_date] || Date.current.beginning_of_month.to_s
  end

  def current_end_date
    end_date_from_params = params[:update_date_range].to_b ? params[:end_date] : nil
    # binding.pry if end_date_from_params
    session[:end_date]   = end_date_from_params || session[:end_date] || Date.current.to_s
  end
end
