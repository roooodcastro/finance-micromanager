# frozen_string_literal: true

class TransactionsController < AbstractAuthenticatedController
  include Pagy::Backend

  before_action :set_transaction, only: %i[edit update destroy]

  def index
    transactions = TransactionSearch
                   .new(Current.profile.transactions.includes(:category, :subcategory, :wallet), search_params)
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
    transaction = Current.profile.transactions.new(transaction_params)

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

  def update_all
    transactions = Current.profile.transactions.where(id: params[:transaction_ids])

    Transaction.transaction do
      transactions.find_each(batch_size: 100) do |transaction|
        transaction.update!(update_all_params)
      end
    end

    render json: { message: t('.success') }
  rescue ActiveRecord::ActiveRecordError, ActiveRecord::Rollback => e
    render json: { message: t('.error', error: e.message) }, status: :unprocessable_entity
  end

  private

  def set_transaction
    @transaction = Current.profile.transactions.find(params[:id])
  end

  def transaction_params
    params
      .require(:transaction)
      .permit(:name, :amount, :transaction_date, :category_id, :amount_type, :wallet_id)
      .merge(amount_currency: Current.profile.currency, created_by: current_user, updated_by: current_user)
      .then { |permitted_params| process_category_id_param(permitted_params) }
  end

  def update_all_params
    transaction_params.permit(:category_id, :subcategory_id, :wallet_id).compact_blank.then do |uap|
      uap[:subcategory_id] = nil if uap[:category_id].present? && uap[:subcategory_id].blank?
      uap
    end
  end

  def process_category_id_param(permitted_params)
    return permitted_params unless permitted_params[:category_id]

    permitted_params[:subcategory_id] = permitted_params[:category_id].split('|')[1]
    permitted_params[:category_id]    = permitted_params[:category_id].split('|')[0]

    permitted_params.delete(:category_id) if Category.find_by(id: permitted_params[:category_id])&.system?

    permitted_params
  end

  def search_params
    params
      .permit(%i[days_to_show exclude_debits exclude_credits limit start_date end_date category_ids wallet_ids])
      .to_h
      .symbolize_keys
  end

  def available_categories
    camelize_props(categories: Current.profile.categories.as_json)
  end
end
