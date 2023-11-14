# frozen_string_literal: true

class TransactionsController < AbstractAuthenticatedController
  include Pagy::Backend

  before_action :set_transaction, only: %i[edit update destroy]

  def index
    transactions = TransactionSearch
                   .new(Current.account.transactions, search_params)
                   .search
                   .order(transaction_date: :desc, created_at: :desc)

    pagy, transactions = pagy(transactions)
    props              = { transactions: transactions.as_json, pagination: pagy_metadata(pagy) }

    respond_to do |format|
      format.html { render inertia: 'transactions/Index', props: camelize_props(props) }
      format.json { render json: props }
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
      .permit(:name, :amount, :transaction_date, :category_id, :amount_type)
      .merge(amount_currency: Current.account.currency)
  end

  def search_params
    params.permit(%i[days_to_show exclude_debits exclude_credits]).to_h.symbolize_keys
  end

  def available_categories
    camelize_props(categories: Current.account.categories.as_json)
  end
end
