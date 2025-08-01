# frozen_string_literal: true

class BudgetsController < AbstractAuthenticatedController
  before_action :set_budget, only: %i[show update destroy reenable]

  def index
    budgets        = Current.profile.budgets.includes(:owner)
    profile_budget = Current.profile.budget
    props          = camelize_props(budgets: budgets.as_json, profile_budget: profile_budget.as_json)

    respond_to do |format|
      format.html { render inertia: 'budgets/Index', props: props }
      format.json { render json: props }
    end
  end

  def show
    props = camelize_props(budget: @budget.as_json)

    respond_to do |format|
      format.html { render inertia: 'budgets/Show', props: props }
      format.json { render json: props }
    end
  end

  def create
    budget = Budget.build_budget(budget_params)

    if budget.save
      Budgets::CreateOrUpdateBudgetInstanceService.call(budget)
      render json: camelize_props(message: t('.success'))
    else
      error = budget.error_messages
      render json:   camelize_props(message: t('.error', error:)),
             status: :unprocessable_entity
    end
  end

  def update
    if @budget.update(budget_params)
      Budgets::CreateOrUpdateBudgetInstanceService.call(@budget)
      Budgets::UpdateBudgetInstancesAmountsService.call(Current.profile)
      render json: camelize_props(message: t('.success'))
    else
      error = @budget.error_messages
      render json:   camelize_props(message: t('.error', error:)),
             status: :unprocessable_entity
    end
  end

  def destroy
    @budget.disable!
    Budgets::DestroyBudgetInstanceService.call(@budget)
    render json: camelize_props(message: t('.success'))
  rescue ActiveRecord::RecordInvalid
    render json: { message: t('.error') }, status: :unprocessable_entity
  end

  def reenable
    @budget.enable!
    Budgets::CreateOrUpdateBudgetInstanceService.call(@budget)
    render json: { message: t('.success') }
  rescue ActiveRecord::RecordInvalid
    render json: { message: t('.error') }, status: :unprocessable_entity
  end

  private

  def set_budget
    @budget = Current.profile.budgets.find(params[:id])
  end

  def budget_params
    params.expect(budget: %i[owner_type owner_id limit_type limit_amount limit_percentage carryover])
  end
end
