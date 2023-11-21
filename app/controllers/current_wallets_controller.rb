# frozen_string_literal: true

class CurrentWalletsController < AbstractAuthenticatedController
  def create
    wallet = current_user.find_available_wallet(params[:wallet_id])

    session[:current_wallet_id] = wallet.id
    render json: { wallet: }
  rescue ActiveRecord::RecordNotFound
    render json: { error: t('.error') }
  end
end
