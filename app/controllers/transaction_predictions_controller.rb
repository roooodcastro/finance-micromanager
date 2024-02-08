# frozen_string_literal: true

class TransactionPredictionsController < AbstractAuthenticatedController
  before_action :set_transaction_prediction, only: %i[edit]

  def index
    transaction_predictions = Current.profile.transaction_predictions.active
    props                   = camelize_props(transaction_predictions: transaction_predictions.as_json)

    respond_to do |format|
      format.html { render inertia: 'transaction_predictions/Index', props: props }
      format.json { render json: props }
    end
  end

  def new
    props = camelize_props(transaction_prediction: Current.profile.transaction_predictions.new.as_json)
    render inertia: 'transaction_predictions/New', props: props
  end

  def edit
    props = camelize_props(transaction_prediction: @transaction_prediction.as_json)
    render inertia: 'transaction_predictions/New', props: props
  end

  private

  def set_transaction_prediction
    @transaction_prediction = Current.profile.transaction_predictions.find(params[:id])
  end
end
