# frozen_string_literal: true

module Budgets
  class CreateOrUpdateBudgetInstanceService < ApplicationService
    attr_reader :budget

    def initialize(budget)
      @budget = budget
    end

    def call
      if budget.current_budget_instance.present?
        budget.current_budget_instance.update!(budget.slice(:limit_amount, :limit_percentage, :limit_type))
      else
        Budgets::BudgetInstanceFactoryService.call(budget).save!
      end

      Budgets::UpdateBudgetInstancesAmountsService.call(budget.profile)
    rescue ActiveRecord::ActiveRecordError => e
      NewRelic::Agent.notice_error(e)
    end
  end
end
