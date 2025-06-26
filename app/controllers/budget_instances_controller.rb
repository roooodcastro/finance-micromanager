# frozen_string_literal: true

class BudgetInstancesController < AbstractAuthenticatedController
  def index
    budget_instance_search = BudgetInstanceSearch.new(BudgetInstance.where(profile: Current.profile), search_params)
    props                  = camelize_props(budget_instances: budget_instance_search.search.map(&:as_json))
    render json: props
  end

  private

  def search_params
    params.permit(%i[start_date end_date owner_type owner_id]).to_h.symbolize_keys
  end
end
