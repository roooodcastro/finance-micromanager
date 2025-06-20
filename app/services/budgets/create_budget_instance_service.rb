# frozen_string_literal: true

module Budgets
  class CreateBudgetInstanceService < ApplicationService
    attr_reader :budget

    def initialize(budget)
      @budget = budget
    end

    def call
      return if budget.current_budget_instance.present?

      Budgets::BudgetInstanceFactoryService.call(budget).save!
      Budgets::UpdateProfileBudgetInstancesService.call(budget.profile)
    rescue ActiveRecord::ActiveRecordError => e
      NewRelic::Agent.notice_error(e)
    end
  end
end
