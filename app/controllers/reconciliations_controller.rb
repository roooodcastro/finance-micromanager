# frozen_string_literal: true

class ReconciliationsController < AbstractAuthenticatedController
  include Pagy::Backend

  before_action :set_reconciliation, only: %i[show update finish destroy]

  def index
    reconciliations       = Current.profile.reconciliations.includes(:reconciliations_wallets).order(date: :desc)
    pagy, reconciliations = pagy(reconciliations, items: current_pagination_items)
    props                 = camelize_props(reconciliations: reconciliations.as_json, pagination: pagy_metadata(pagy))

    respond_to do |format|
      format.html { render inertia: 'reconciliations/Index', props: props }
      format.json { render json: props }
    end
  end

  def show
    wallet_balances = WalletBalanceSyncQuery
                      .run(profile_id: Current.profile.id, end_date: @reconciliation.date)
                      .index_by(&:wallet_id)
                      .transform_values(&:amount)

    props = camelize_props(reconciliation: @reconciliation.as_json, wallet_balances: wallet_balances)

    respond_to do |format|
      format.html { render inertia: 'reconciliations/Show', props: props }
      format.json { render json: props }
    end
  end

  def create
    @reconciliation = Current.profile.reconciliations.new(reconciliation_params)

    if @reconciliation.save
      Transactions::SyncProfileAndWalletBalances.call(profile: Current.profile)

      render json: camelize_props(reconciliation: @reconciliation.as_json, message: message('.success'))
    else
      render json:   { message: message('.error', error: @reconciliation.errors.full_messages.join(', ')) },
             status: :unprocessable_entity
    end
  end

  def update
    if @reconciliation.update(reconciliation_params)
      render json: { message: message('.success') }
    else
      render json:   { message: message('.error', error: @reconciliation.errors.full_messages.join(', ')) },
             status: :unprocessable_entity
    end
  end

  def finish
    if ::Reconciliations::FinishReconciliation.call(@reconciliation)
      render json: { message: message('.success_without_correction') }
    else
      render json:   { message: message('.error', error: @reconciliation.errors.full_messages.join(', ')) },
             status: :unprocessable_entity
    end
  end

  # Sets status as cancelled
  def destroy
    if @reconciliation.update(status: :cancelled)
      render json: { message: message('.success') }
    else
      render json:   { message: message('.error', error: @reconciliation.errors.full_messages.join(', ')) },
             status: :unprocessable_entity
    end
  end

  private

  def reconciliation_params
    params.require(:reconciliation).permit(:date)
  end

  def set_reconciliation
    @reconciliation = Current.profile.reconciliations.find(params[:id])
  end

  def message(scope, options = {})
    t(scope, **options.merge(date: I18n.l(@reconciliation.date)))
  end
end
