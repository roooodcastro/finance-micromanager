# frozen_string_literal: true

class TransactionPredictionsController < AbstractAuthenticatedController
  def index
    transaction_predictions = Current.profile.transaction_predictions.active
    props                   = camelize_props(transaction_predictions: transaction_predictions.as_json)

    respond_to do |format|
      format.html { render inertia: 'transaction_predictions/Index', props: props }
      format.json { render json: props }
    end
  end
end
