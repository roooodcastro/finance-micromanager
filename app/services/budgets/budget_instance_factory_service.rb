# frozen_string_literal: true

module Budgets
  class BudgetInstanceFactoryService < ApplicationService
    attr_reader :budget, :reference_date

    def initialize(budget, reference_date = Time.current)
      @budget         = budget
      @reference_date = reference_date
    end

    def call
      return existing_budget_instance if existing_budget_instance

      BudgetInstance.new(
        profile:          budget.profile,
        owner:            budget.owner,
        limit_type:       budget.limit_type,
        limit_amount:     budget.limit_amount,
        limit_percentage: budget.limit_percentage,
        budget:           budget,
        start_date:       reference_date.beginning_of_month,
        end_date:         reference_date.end_of_month.end_of_day
      ).tap do |budget_instance|
        budget_instance.used_amount = calculate_used_amount(budget_instance)
      end
    end

    private

    def calculate_used_amount(budget_instance)
      return 0 unless budget.carryover?
      return 0 if budget_instance.previous_instance.nil?

      -budget_instance.previous_instance.carryover_amount
    end

    def existing_budget_instance
      @existing_budget_instance ||= BudgetInstance.find_by(
        profile:    budget.profile,
        owner:      budget.owner,
        start_date: reference_date.beginning_of_month,
        end_date:   reference_date.end_of_month.end_of_day
      )
    end
  end
end
