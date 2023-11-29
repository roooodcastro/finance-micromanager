# frozen_string_literal: true

module SetCurrentAttributes
  extend ActiveSupport::Concern

  included do
    before_action :set_current_attributes
  end

  def set_current_attributes
    # Current.locale is set in Localizeable concern
    Current.wallet = current_wallet if user_signed_in?
    Current.user   = current_user if user_signed_in?

    CurrentDateRange.start_date = Time.zone.parse(current_start_date)
    CurrentDateRange.end_date   = Time.zone.parse(current_end_date)
  end

  def current_wallet
    wallet_id = session[:current_wallet_id] || current_user.default_wallet_id
    current_user.find_available_wallet(wallet_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def current_start_date
    session[:start_date] = params[:start_date] || session[:start_date] || Date.current.beginning_of_month.to_s
  end

  def current_end_date
    session[:end_date] = params[:end_date] || session[:end_date] || Date.current.to_s
  end
end
