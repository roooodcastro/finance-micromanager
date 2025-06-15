# frozen_string_literal: true

module Budgets
  class CreateBudgetInstanceService < ApplicationService
    attr_reader :budget

    def initialize(budget)
      @budget = budget
    end

    def call
      return if budget.current_budget_instance.present?

      create_budget_instance!(budget)
      Budgets::UpdateProfileBudgetInstancesService.call(budget.profile)
    rescue ActiveRecord::ActiveRecordError => e
      NewRelic::Agent.notice_error(e)
    end

    private

    def create_budget_instance!(budget)
      budget_instance = BudgetInstance.build_from_budget(budget)
      budget_instance.assign_attributes(
        start_date: Date.current.beginning_of_month,
        end_date:   Date.current.end_of_month.end_of_day
      )

      budget_instance.tap(&:save!)
    end
  end
end
