# frozen_string_literal: true

class WalletsController < AbstractAuthenticatedController
  before_action :set_wallet, only: %i[update destroy reenable]

  def index
    wallets = Current.profile.wallets.order(:name)
    wallets = wallets.active unless params[:show_disabled].to_b
    props   = camelize_props(wallets: wallets.as_json)

    respond_to do |format|
      format.html { render inertia: 'wallets/Index', props: camelize_props(props) }
      format.json { render json: props }
    end
  end

  def create
    wallet = Current.profile.wallets.new(wallet_params)

    if wallet.save
      render json: camelize_props(message: t('.success', name: wallet.name))
    else
      render json:   camelize_props(message: t('.error', error: wallet.error_messages)),
             status: :unprocessable_entity
    end
  end

  def update
    if @wallet.update(wallet_params)
      render json: camelize_props(message: t('.success', name: @wallet.name))
    else
      render json: camelize_props(
        message: t('.error', name: @wallet.name_was, error: @wallet.error_messages)
      ), status: :unprocessable_entity
    end
  end

  def destroy
    if @wallet.disable!
      render json: camelize_props(message: t('.success', name: @wallet.name))
    else
      render json: camelize_props(
        message: t('.error', name: @wallet.name, error: @wallet.error_messages)
      ), status: :unprocessable_entity
    end
  end

  def reenable
    @wallet.enable!

    render json: camelize_props(message: t('.success', name: @wallet.name))
  end

  private

  def set_wallet
    @wallet = Current.profile.wallets.find(params[:id])
  end

  def wallet_params
    params.expect(wallet: [:name])
  end
end
