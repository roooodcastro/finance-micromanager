# frozen_string_literal: true

module SetCurrentAttributes
  extend ActiveSupport::Concern

  included do
    before_action :set_current_attributes
  end

  def set_current_attributes
    Current.wallet = current_wallet if user_signed_in?
    # Current.locale is set in Localizeable concern
    Current.user   = current_user if user_signed_in?
  end

  def current_wallet
    wallet_id = session[:current_wallet_id] || current_user.default_wallet_id
    current_user.find_available_wallet(wallet_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
