# frozen_string_literal: true

class CurrentAccountsController < AbstractAuthenticatedController
  def create
    account = current_user.find_available_account(params[:account_id])

    session[:current_account_id] = account.id
    render json: { account: }
  rescue ActiveRecord::RecordNotFound
    render json: { error: t('.error') }
  end
end
