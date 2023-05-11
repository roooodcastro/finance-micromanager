# frozen_string_literal: true

module SetCurrentAttributes
  def set_current_attributes
    # Current.account = Account.find(session[:account_id])
    Current.account = Account.first
  end
end
