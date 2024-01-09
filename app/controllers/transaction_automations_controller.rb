# frozen_string_literal: true

class TransactionAutomationsController < AbstractAuthenticatedController
  def index
    transaction_automations = Current.profile.transaction_automations
    props                   = camelize_props(transaction_automations: transaction_automations.as_json)

    respond_to do |format|
      format.html { render inertia: 'transaction_automations/Index', props: props }
      format.json { render json: props }
    end
  end

  private

  def transaction_automation_params
    params.require(:transaction_automation).permit(
      :transaction_name,
      :transaction_amount,
      :transaction_category_id,
      :transaction_wallet_id,
      :schedule_type,
      :schedule_interval,
      :next_schedule_date
    )
  end
end
