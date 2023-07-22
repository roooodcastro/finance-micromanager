# frozen_string_literal: true

module SetCurrentAttributes
  extend ActiveSupport::Concern

  included do
    before_action :set_current_attributes
  end

  def set_current_attributes
    Current.account = current_account if user_signed_in?
    # Current.locale is set in Localizeable concern
  end

  def current_account
    account_id = session[:current_account_id] || current_user.default_account_id
    current_user.accounts.find_by(id: account_id)
  end
end
