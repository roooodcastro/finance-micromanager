# frozen_string_literal: true

module Budgets
  class UpdateProfileBudgetInstancesService < ApplicationService
    attr_reader :profile

    def initialize(profile)
      @profile = profile
    end

    def call
      ActiveRecord::Base.transaction do
        # First calculate the used amount for each category budget
        category_budget_instances.each(&method(:calculate_used_amount))
        # Then recalculate the limit of the profile budget, if it exists and has a percentage limit type
        calculate_percentage_limit_amount(profile_budget_instance)
        # Then recalculate all the category budgets which have a percentage limit type
        category_budget_instances.each(&method(:calculate_percentage_limit_amount))
        # Lastly, recalculate the remainder category budget, if it exists
        calculate_remainder_limit_amount

        # Now save everything
        profile_budget_instance&.save!
        category_budget_instances.each(&:save!)
      rescue ActiveRecord::ActiveRecordError => e
        NewRelic::Agent.notice_error(e)
        raise ActiveRecord::Rollback
      end
    end

    private

    def calculate_profile_income(start_date, end_date)
      @calculate_profile_income ||= begin
        sum = Transaction.where(profile:).newer_than(start_date).older_than(end_date).exclude_debits.sum(:amount_cents)
        Money.new(sum, profile.currency_object)
      end
    end

    def calculate_percentage_limit_amount(budget_instance)
      return unless budget_instance&.limit_type_percentage?

      profile_income    = calculate_profile_income(budget_instance.start_date, budget_instance.end_date)
      limit_reference   = profile_budget_instance&.limit_amount if budget_instance != profile_budget_instance
      limit_reference ||= profile_income

      budget_instance.limit_amount = limit_reference * (budget_instance.limit_percentage / 100.0)
    end

    def calculate_remainder_limit_amount
      budget_instance = category_budget_instances.find(&:limit_type_remainder?)
      return unless budget_instance

      categories_limit_amount = category_budget_instances.sum(&:limit_amount)
      profile_limit_amount    = profile_budget_instance&.limit_amount || calculate_profile_income(
        budget_instance.start_date, budget_instance.end_date
      )

      budget_instance.limit_amount = [profile_limit_amount - categories_limit_amount, 0].max
    end

    def calculate_used_amount(budget_instance)
      transactions_in_period = transactions_in_period_for(budget_instance)

      sum                         = transactions_in_period.sum(:amount_cents) * -1
      budget_instance.used_amount = Money.new(sum, profile.currency_object)
    end

    def profile_budget_instance
      return @profile_budget_instance if defined?(@profile_budget_instance)

      @profile_budget_instance ||= BudgetInstance.for_current_date.find_by(profile: profile, owner: profile)
    end

    def category_budget_instances
      return @category_budget_instances if defined?(@category_budget_instances)

      @category_budget_instances ||= BudgetInstance.for_current_date.where(profile: profile, owner_type: 'Category')
    end

    def transactions_in_period_for(budget_instance)
      return [] unless budget_instance.owner.is_a?(Category)

      profile.transactions.newer_than(budget_instance.start_date).older_than(budget_instance.end_date)
             .where(category: budget_instance.owner)
    end
  end
end
