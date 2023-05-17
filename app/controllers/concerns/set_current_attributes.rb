# frozen_string_literal: true

module SetCurrentAttributes
  extend ActiveSupport::Concern

  def set_current_attributes
    # Current.account = Account.find(session[:account_id])
    Current.account = Account.first
  end
end
