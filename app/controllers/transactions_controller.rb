# frozen_string_literal: true

class TransactionsController < AbstractAuthenticatedController
  before_action :set_transaction, only: %i[show edit update destroy]

  def index
    transactions = Current.account.transactions.includes(:category)

    render inertia: 'transactions/Index', props: { transactions: transactions.as_json(include: :category) }
  end

  def show
    render inertia: 'transactions/Show'
  end

  def new
    transaction = Transaction.new
    categories  = Current.account.categories

    render inertia: 'transactions/New', props: { transaction:, categories: }
  end

  def edit
    categories = Current.account.categories

    render inertia: 'transactions/Edit', props: { transaction: @transaction, categories: categories }
  end

  def create
    transaction = Transaction.new(transaction_params)

    return redirect_to transactions_path, success: t('.success') if transaction.save

    flash.now[:error] = t('.error', error: transaction.errors.full_messages)
    categories        = Current.account.categories
    render inertia: 'transactions/New', props: { transaction:, categories: }
  end

  def update
    if @transaction.update(transaction_params)
      flash[:success] = t('.success')
      redirect_to transactions_path
    else
      flash.now[:error] = t('.error', error: @transaction.errors.full_messages)

      categories = Current.account.categories
      render inertia: 'transactions/Edit', props: { transaction: @transaction, categories: categories }
    end
  end

  def destroy
    @transaction.destroy

    redirect_to transactions_path, success: t('.success')
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params
      .require(:transaction)
      .permit(:name, :amount, :transaction_date, :category_id)
      .merge(account: Current.account)
  end
end
