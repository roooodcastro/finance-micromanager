# frozen_string_literal: true

class BudgetsController < AbstractAuthenticatedController
  before_action :set_budget, only: %i[update destroy reenable]

  def index
    budgets       = Current.profile.budgets
    props         = camelize_props(budgets: budgets.as_json)

    respond_to do |format|
      format.html { render inertia: 'budgets/Index', props: props }
      format.json { render json: props }
    end
  end

  def create
    budget = Current.profile.budgets.new(budget_params)

    if budget.save
      render json: camelize_props(message: t('.success'))
    else
      error = budget.error_messages
      render json:   camelize_props(message: t('.error', error:)),
             status: :unprocessable_entity
    end
  end

  def update
    if @budget.update(budget_params)
      render json: camelize_props(message: t('.success'))
    else
      error = @budget.error_messages
      render json:   camelize_props(message: t('.error', error:)),
             status: :unprocessable_entity
    end
  end

  def destroy
    @budget.disable!
    render json: camelize_props(message: t('.success'))
  rescue ActiveRecord::RecordInvalid
    render json: { message: t('.error') }, status: :unprocessable_entity
  end

  def reenable
    @budget.enable!
    render json: { message: t('.success') }
  rescue ActiveRecord::RecordInvalid
    render json: { message: t('.error') }, status: :unprocessable_entity
  end

  private

  def set_budget
    @budget = Current.profile.budgets.find(params[:id])
  end

  def budget_params
    params.require(:budget).permit(:owner_type, :owner_id, :limit_type, :limit_amount, :limit_percentage)
  end
end
