# frozen_string_literal: true

class TransactionsController < AbstractVueController
  before_action :set_transaction, only: %i[show edit update destroy]

  def index
    @transactions = Transaction.all

    render inertia: 'transactions/Index'
  end

  def show
    render inertia: 'transactions/Show'
  end

  def new
    @transaction = Transaction.new

    render inertia: 'transactions/New'
  end

  def edit
    render inertia: 'transactions/Edit'
  end

  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to transaction_url(@transaction), notice: t('.success') }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to transaction_url(@transaction), notice: t('.success') }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to transactions_url, notice: t('.success') }
      format.json { head :no_content }
    end
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit.merge(account: Current.account)
  end
end
