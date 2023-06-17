# frozen_string_literal: true

class AccountsController < AbstractAuthenticatedController
  before_action :set_account, only: %i[show edit update destroy]

  def index
    accounts = Account.active.where(user: current_user)

    render inertia: 'accounts/Index', props: { accounts: accounts, current_account: Current.account }
  end

  def show
    render inertia: 'accounts/Show'
  end

  def new
    account = Account.new

    render inertia: 'accounts/New', props: { account: }
  end

  def edit
    render inertia: 'accounts/Edit', props: { account: @account }
  end

  def create
    account = current_user.accounts.new(account_params)

    return redirect_to accounts_path, success: t('.success') if account.save

    flash.now[:error] = t('.error', error: account.errors.full_messages)
    render inertia: 'accounts/New', props: { account: }
  end

  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to account_url(@account), notice: t('.success') }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @account.disabled!

    redirect_to accounts_path, success: t('.success')
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:currency)
  end
end
