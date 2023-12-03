# frozen_string_literal: true

class TransactionsController < AbstractAuthenticatedController
  include Pagy::Backend

  before_action :set_transaction, only: %i[edit update destroy]

  def index
    transactions = TransactionSearch
                   .new(Current.wallet.transactions.includes(:category, :subcategory), search_params)
                   .search
                   .order(transaction_date: :desc, created_at: :desc)

    pagy, transactions = pagy(transactions, items: current_pagination_items)
    props              = { transactions: transactions.as_json, pagination: pagy_metadata(pagy) }

    respond_to do |format|
      format.html { render inertia: 'transactions/Index', props: camelize_props(props) }
      format.json { render json: props }
    end
  end

  def new
    props = { transaction: Transaction.new.as_json, skip_floating_action_button: true }.merge(available_categories)
    render inertia: 'transactions/New', props: camelize_props(props)
  end

  def edit
    render inertia: 'transactions/Edit',
           props:   { transaction: camelize_props(@transaction.as_json) }.merge(available_categories)
  end

  def create
    transaction = Current.wallet.transactions.new(transaction_params)

    if transaction.save
      render json: camelize_props(message: t('.success'))
    else
      render json:   camelize_props(message: t('.error', error: transaction.errors.full_messages.join(', '))),
             status: :unprocessable_entity
    end
  end

  def update
    if @transaction.update(transaction_params.except(:created_by))
      render json: camelize_props(message: t('.success'))
    else
      render json:   camelize_props(message: t('.error', error: @transaction.errors.full_messages.join(', '))),
             status: :unprocessable_entity
    end
  end

  def destroy
    transaction_id = @transaction.id
    @transaction.destroy

    render json: camelize_props(transaction_id: transaction_id, message: t('.success'))
  end

  private

  def set_transaction
    @transaction = Current.wallet.transactions.find(params[:id])
  end

  def transaction_params
    params
      .require(:transaction)
      .permit(:name, :amount, :transaction_date, :category_id, :amount_type)
      .merge(amount_currency: Current.wallet.currency, created_by: current_user, updated_by: current_user)
      .then do |permitted_params|
        break permitted_params unless permitted_params[:category_id]

        permitted_params[:subcategory_id] = permitted_params[:category_id].split(',')[1]
        permitted_params[:category_id]    = permitted_params[:category_id].split(',')[0]
        permitted_params
      end
  end

  def search_params
    params.permit(%i[days_to_show exclude_debits exclude_credits limit start_date end_date]).to_h.symbolize_keys
  end

  def available_categories
    camelize_props(categories: Current.wallet.categories.as_json)
  end
end
