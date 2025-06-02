# frozen_string_literal: true

module Budgets
  class CreateBudgetInstancesService < ApplicationService
    def call
      Budget.active.each do |budget|
        budget_instance = BudgetInstance.build_from_budget(budget)
        budget_instance.assign_attributes(
          start_date: Date.current.beginning_of_month,
          end_date:   Date.current.end_of_month
        )

        budget_instance.save!
      rescue ActiveRecord::ActiveRecordError => e
        NewRelic::Agent.notice_error(e)
      end
    end
  end
end
