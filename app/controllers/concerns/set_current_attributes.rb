# frozen_string_literal: true

module SetCurrentAttributes
  extend ActiveSupport::Concern

  def set_current_attributes
    Current.account = current_user.accounts.find_by(id: session[:current_account_id])
  end
end
