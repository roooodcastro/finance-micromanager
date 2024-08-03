# frozen_string_literal: true

class ReconciliationsWalletsController < AbstractAuthenticatedController
  before_action :set_reconciliation
  before_action :set_reconciliation_wallet, only: :create

  rescue_from(ActiveRecord::RecordNotFound) do |_|
    render json: { message: t('.create.not_found') }, status: :not_found
  end

  def create
    if @reconciliation_wallet.update(reconciliation_wallet_params)
      render json: {}
    else
      render json:   { message: t('.error', error: @reconciliation_wallet.error_messages) },
             status: :unprocessable_entity
    end
  end

  private

  def reconciliation_wallet_params
    params.require(:reconciliation_wallet).permit(:balance_amount).merge(wallet:)
  end

  def set_reconciliation
    @reconciliation = Current.profile.reconciliations.find(params[:reconciliation_id])
  end

  def wallet
    @wallet ||= Current.profile.wallets.find(params.dig(:reconciliation_wallet, :wallet_id))
  end

  def set_reconciliation_wallet
    @reconciliation_wallet = @reconciliation.reconciliations_wallets.find_by(id: params[:id]) ||
                             @reconciliation.reconciliations_wallets.new(reconciliation_wallet_params)
  end
end
