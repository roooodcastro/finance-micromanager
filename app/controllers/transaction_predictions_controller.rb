# frozen_string_literal: true

class TransactionPredictionsController < AbstractAuthenticatedController
  before_action :set_transaction_prediction, only: %i[show edit update disable reenable destroy]

  def index
    transaction_predictions = Current.profile.transaction_predictions
    props                   = camelize_props(transaction_predictions: transaction_predictions.as_json)

    respond_to do |format|
      format.html { render inertia: 'transaction_predictions/Index', props: props }
      format.json { render json: props }
    end
  end

  def show
    props = camelize_props(transaction_prediction: @transaction_prediction.as_json)

    respond_to do |format|
      format.html { render inertia: 'transaction_predictions/Show', props: props }
      format.json { render json: props }
    end
  end

  def new
    props = camelize_props(transaction_prediction: Current.profile.transaction_predictions.new.as_json)
    render inertia: 'transaction_predictions/New', props: props
  end

  def edit
    props = camelize_props(transaction_prediction: @transaction_prediction.as_json)
    render inertia: 'transaction_predictions/Edit', props: props
  end

  def create
    transaction_prediction = Current.profile.transaction_predictions.new(transaction_prediction_params)

    if transaction_prediction.save
      flash[:success] = t('.success', name: transaction_prediction.name)
      redirect_to transaction_predictions_path
    else
      flash.now[:error] = t('.error', error: transaction_prediction.error_messages)
      props             = camelize_props(transaction_prediction: transaction_prediction.as_json)
      render inertia: 'transaction_predictions/New', props: props
    end
  end

  def update
    if @transaction_prediction.update(transaction_prediction_params)
      flash[:success] = t('.success', name: @transaction_prediction.name)
      redirect_to transaction_predictions_path
    else
      flash.now[:error] = t('.error', error: @transaction_prediction.error_messages)
      props             = camelize_props(transaction_prediction: @transaction_prediction.as_json)
      render inertia: 'transaction_predictions/Edit', props: props
    end
  end

  def destroy
    @transaction_prediction.destroy!

    render json: camelize_props(message: t('.success', name: @transaction_prediction.name))
  end

  def disable
    @transaction_prediction.disable!

    render json: camelize_props(message: t('.success', name: @transaction_prediction.name))
  end

  def reenable
    @transaction_prediction.enable!

    render json: camelize_props(message: t('.success', name: @transaction_prediction.name))
  end

  private

  def set_transaction_prediction
    @transaction_prediction = Current.profile.transaction_predictions.find(params[:id])
  end

  def transaction_prediction_params
    params.expect(transaction_prediction: %i[name rules_json])
  end
end
