# frozen_string_literal: true

class WalletsController < AbstractAuthenticatedController
  before_action :set_wallet, only: %i[show edit update destroy]

  def index
    wallets = current_user.available_wallets
    props   = camelize_props(
      wallets:        wallets.as_json,
      current_wallet: Current.wallet.as_json
    )

    respond_to do |format|
      format.html { render inertia: 'wallets/Index', props: props }
      format.json { render json: props }
    end
  end

  def show
    render inertia: 'wallets/Show'
  end

  def new
    wallet = Wallet.new

    render inertia: 'wallets/New', props: { wallet: camelize_props(wallet.as_json) }
  end

  def edit
    render inertia: 'wallets/Edit', props: { wallet: camelize_props(@wallet.as_json) }
  end

  def create
    wallet = current_user.wallets.new(wallet_params)

    return redirect_to wallets_path, success: t('.success') if wallet.save

    flash.now[:error] = t('.error', name: wallet.display_name, error: wallet.errors.full_messages.join(', '))
    render inertia: 'wallets/New', props: { wallet: camelize_props(wallet.as_json) }
  end

  def update
    updated = @wallet.update(wallet_params)

    return redirect_to wallets_path, success: t('.success', name: @wallet.display_name) if updated

    flash.now[:error] = t('.error', name: @wallet.display_name, error: @wallet.errors.full_messages.join(', '))
    render inertia: 'wallets/Edit', props: { wallet: camelize_props(@wallet.as_json) }
  end

  def destroy
    @wallet.disabled!

    render json: camelize_props(wallet_id: @wallet.id, message: t('.success', name: @wallet.display_name))
  end

  private

  def set_wallet
    @wallet = current_user.find_available_wallet(params[:id])
  end

  def wallet_params
    params.require(:wallet).permit(:currency, :name)
  end
end
