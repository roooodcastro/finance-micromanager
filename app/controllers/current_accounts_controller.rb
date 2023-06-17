# frozen_string_literal: true

class CurrentAccountsController < AbstractAuthenticatedController
  def create
    account = current_user.accounts.find(params[:account_id])

    if account.present?
      session[:current_account_id] = account.id
      render json: { account: }
    else
      render json: { error: t('.error') }
    end
  end
end
