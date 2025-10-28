# frozen_string_literal: true

class TransactionAutomationsController < AbstractAuthenticatedController
  before_action :set_transaction_automation, only: %i[show update destroy disable reenable]

  def index
    automations = Current
                  .profile
                  .transaction_automations
                  .includes(:transaction_category, :transaction_subcategory, :transaction_wallet)
                  .order(:scheduled_date)

    props       = camelize_props(transaction_automations: automations.as_json)

    respond_to do |format|
      format.html { render inertia: 'transaction_automations/Index', props: props }
      format.json { render json: props }
    end
  end

  def show
    props = camelize_props(transaction_automation: @transaction_automation.as_json)

    respond_to do |format|
      format.html { render inertia: 'transaction_automations/Show', props: props }
      format.json { render json: props }
    end
  end

  def create
    transaction_automation = Current.profile.transaction_automations.new(transaction_automation_params)

    if transaction_automation.save
      render json: camelize_props(message: t('.success'))
    else
      error = transaction_automation.error_messages
      render json:   camelize_props(message: t('.error', error:)),
             status: :unprocessable_entity
    end
  end

  def update
    if @transaction_automation.update(transaction_automation_params)

      render json: camelize_props(message: t('.success'))
    else
      error = @transaction_automation.error_messages
      render json:   camelize_props(message: t('.error', error:)),
             status: :unprocessable_entity
    end
  end

  def destroy
    @transaction_automation.destroy!

    render json: camelize_props(message: t('.success'))
  end

  def disable
    @transaction_automation.disable!

    render json: camelize_props(message: t('.success'))
  end

  def reenable
    @transaction_automation.enable!

    render json: camelize_props(message: t('.success'))
  end

  private

  def set_transaction_automation
    @transaction_automation = Current.profile.transaction_automations.find(params[:id])
  end

  def transaction_automation_params
    params.expect(
      transaction_automation: %i[
        transaction_name
        transaction_amount
        transaction_category_id
        transaction_wallet_id
        transaction_transaction_automation_id
        schedule_type
        schedule_interval
        schedule_day
        scheduled_date
        schedule_custom_rule
        create_at_start_of_period
        weekend_rule
      ]
    ).then { |permitted_params| process_category_id_param(permitted_params) }
  end

  def process_category_id_param(permitted_params)
    return permitted_params unless permitted_params[:transaction_category_id]

    permitted_params[:transaction_category_id]    =
      Category.split_compose_category_id(permitted_params[:transaction_category_id]).first
    permitted_params[:transaction_subcategory_id] =
      Category.split_compose_category_id(permitted_params[:transaction_category_id]).second

    if Category.find_by(id: permitted_params[:transaction_category_id])&.system?
      permitted_params.delete(:transaction_category_id)
    end

    permitted_params
  end
end
