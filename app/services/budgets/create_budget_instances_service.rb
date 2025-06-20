# frozen_string_literal: true

module Budgets
  class CreateBudgetInstancesService < ApplicationService
    def call
      Profile.active.each do |profile|
        profile_budget_instance = create_budget_instance!(profile.budget)

        budgets          = profile.budgets.where(owner_type: 'Category').where.not(limit_type: :remainder)
        budget_instances = budgets.map { |budget| create_budget_instance!(budget, profile_budget_instance) }

        remainder_budget = profile.budgets.limit_type_remainder.first
        create_budget_instance!(remainder_budget, profile_budget_instance, budget_instances)
      rescue ActiveRecord::ActiveRecordError => e
        NewRelic::Agent.notice_error(e)
      end
    end

    private

    def create_budget_instance!(budget, profile_budget_instance = nil, budget_instances = nil)
      return unless budget

      budget_instance = Budgets::BudgetInstanceFactoryService.call(budget)

      calculate_percetage_limit_amount(profile_budget_instance, budget_instance)
      calculate_remainder_limit_amount(profile_budget_instance, budget_instance, budget_instances)

      budget_instance.tap(&:save!)
    end

    def calculate_percetage_limit_amount(profile_budget_instance, budget_instance)
      return unless budget_instance.limit_type_percentage?

      limit_reference              = profile_budget_instance&.limit_amount.to_f
      budget_instance.limit_amount = limit_reference * (budget_instance.limit_percentage / 100.0)
    end

    def calculate_remainder_limit_amount(profile_budget_instance, budget_instance, other_budget_instances)
      return unless budget_instance.limit_type_remainder?

      limit_reference              = profile_budget_instance&.limit_amount.to_f
      other_limit_sum              = other_budget_instances.sum(&:limit_amount).to_f
      budget_instance.limit_amount = [limit_reference - other_limit_sum, 0].max
    end
  end
end
