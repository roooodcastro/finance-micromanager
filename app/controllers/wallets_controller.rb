# frozen_string_literal: true

class WalletsController < AbstractAuthenticatedController
  def index
    wallets = Current.profile.wallets.order(:name)
    wallets = wallets.active unless params[:show_disabled].to_b

    render json: camelize_props(wallets: wallets.as_json)
  end

  def create
    wallet = Current.profile.wallets.new(wallet_params)

    if wallet.save
      render json: camelize_props(message: t('.success', name: wallet.name))
    else
      render json:   camelize_props(message: t('.error', error: wallet.errors.full_messages.join(', '))),
             status: :unprocessable_entity
    end
  end

  private

  def wallet_params
    params.require(:wallet).permit(:name)
  end
end
