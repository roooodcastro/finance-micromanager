# frozen_string_literal: true

class TransactionsController < AbstractAuthenticatedController
  before_action :set_transaction, only: %i[edit update destroy]

  def index
    transactions = Current.account.transactions.includes(:category).as_json

    respond_to do |format|
      format.html { render inertia: 'transactions/Index', props: camelize_props(transactions:) }
      format.json { render json: { transactions: } }
    end
  end

  def new
    render inertia: 'transactions/New', props: { transaction: {} }.merge(available_categories)
  end

  def edit
    render inertia: 'transactions/Edit',
           props:   { transaction: camelize_props(@transaction.as_json) }.merge(available_categories)
  end

  def create
    transaction = Current.account.transactions.new(transaction_params)

    return redirect_to transactions_path, success: t('.success') if transaction.save

    flash.now[:error] = t('.error', error: transaction.errors.full_messages)
    render inertia: 'transactions/New',
           props:   { transaction: camelize_props(transaction.as_json) }.merge(available_categories)
  end

  def update
    if @transaction.update(transaction_params)
      flash[:success] = t('.success')
      redirect_to transactions_path
    else
      flash.now[:error] = t('.error', error: @transaction.errors.full_messages)

      render inertia: 'transactions/Edit',
             props:   { transaction: camelize_props(@transaction.as_json) }.merge(available_categories)
    end
  end

  def destroy
    @transaction.destroy

    redirect_to transactions_path, success: t('.success')
  end

  private

  def set_transaction
    @transaction = Current.account.transactions.find(params[:id])
  end

  def transaction_params
    params
      .require(:transaction)
      .permit(:name, :amount, :transaction_date, :category_id)
      .merge(amount_currency: Current.account.currency)
  end

  def available_categories
    camelize_props(categories: Current.account.categories.as_json)
  end
end
