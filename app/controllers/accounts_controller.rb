# frozen_string_literal: true

class AccountsController < AbstractAuthenticatedController
  before_action :set_account, only: %i[show edit update destroy]

  def index
    accounts = current_user.available_accounts

    render inertia: 'accounts/Index', props: camelize_props(
      accounts:        accounts.as_json,
      current_account: Current.account.as_json
    )
  end

  def show
    render inertia: 'accounts/Show'
  end

  def new
    account = Account.new

    render inertia: 'accounts/New', props: { account: camelize_props(account.as_json) }
  end

  def edit
    render inertia: 'accounts/Edit', props: { account: camelize_props(@account.as_json) }
  end

  def create
    account = current_user.accounts.new(account_params)

    return redirect_to accounts_path, success: t('.success') if account.save

    flash.now[:error] = t('.error', name: account.display_name, error: account.errors.full_messages.join(', '))
    render inertia: 'accounts/New', props: { account: camelize_props(account.as_json) }
  end

  def update
    updated = @account.update(account_params)

    return redirect_to accounts_path, success: t('.success', name: @account.display_name) if updated

    flash.now[:error] = t('.error', name: @account.display_name, error: @account.errors.full_messages.join(', '))
    render inertia: 'accounts/Edit', props: { account: camelize_props(@account.as_json) }
  end

  def destroy
    @account.disabled!

    redirect_to accounts_path, success: t('.success')
  end

  private

  def set_account
    @account = current_user.find_available_account(params[:id])
  end

  def account_params
    params.require(:account).permit(:currency, :name)
  end
end
