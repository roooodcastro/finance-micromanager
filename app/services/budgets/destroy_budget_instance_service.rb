# frozen_string_literal: true

module Budgets
  class DestroyBudgetInstanceService < ApplicationService
    attr_reader :budget

    def initialize(budget)
      @budget = budget
    end

    def call
      budget_instance = budget.current_budget_instance
      return unless budget_instance

      budget_instance.destroy!
      Budgets::UpdateProfileBudgetInstancesService.call(budget.profile)
    rescue ActiveRecord::ActiveRecordError => e
      NewRelic::Agent.notice_error(e)
    end
  end
end
