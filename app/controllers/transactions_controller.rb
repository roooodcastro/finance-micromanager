# frozen_string_literal: true

class TransactionsController < AbstractAuthenticatedController
  include Pagy::Backend

  before_action :set_transaction, only: %i[update destroy]

  def index
    transaction_search = TransactionSearch.new(Current.profile.transactions, search_params)

    statistics   = TransactionStatisticsSerializer.new(transaction_search).as_json if params[:include_statistics]
    transactions = transaction_search
                   .search
                   .order(transaction_date: :desc, created_at: :desc)
                   .includes(:category, :subcategory, :wallet)

    pagy, transactions = pagy(transactions, limit: current_pagination_limit)
    props              = { transactions: transactions.as_json, pagination: pagy_metadata(pagy) }
    props[:statistics] = statistics if params[:include_statistics]

    respond_to do |format|
      format.html { render inertia: 'transactions/Index', props: camelize_props(props) }
      format.json { render json: props }
    end
  end

  def create
    transaction = Current.profile.transactions.new(transaction_params)

    if transaction.save
      render json: camelize_props(message: t('.success'))
    else
      render json:   camelize_props(message: t('.error', error: transaction.error_messages)),
             status: :unprocessable_entity
    end
  end

  def update
    if @transaction.update(transaction_params.except(:created_by))
      render json: camelize_props(message: t('.success'))
    else
      render json:   camelize_props(message: t('.error', error: @transaction.error_messages)),
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
      .merge(created_by: current_user, updated_by: current_user)
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

    permitted_params[:category_id], permitted_params[:subcategory_id] = Category.split_compose_category_id(
      permitted_params[:category_id]
    )

    if Category.exists?(id: permitted_params[:category_id], category_type: :system)
      permitted_params.delete(:category_id)
    end

    permitted_params
  end

  def search_params
    params
      .permit(%i[days_to_show exclude_debits exclude_credits limit start_date end_date category_ids wallet_ids
                 transaction_automation_id search_string])
      .to_h
      .symbolize_keys
  end

  def available_categories
    camelize_props(categories: Current.profile.categories.as_json)
  end
end
