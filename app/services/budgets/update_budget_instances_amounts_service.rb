# frozen_string_literal: true

module Budgets
  class UpdateBudgetInstancesAmountsService < ApplicationService
    attr_reader :profile, :reference_dates

    def initialize(profile, reference_dates = Time.current)
      @profile         = profile
      @reference_dates = reference_dates
    end

    def call
      ActiveRecord::Base.transaction do
        parse_reference_dates.each do |reference_date|
          # First, fetch the data for the specified period
          category_budget_instances = fetch_category_budget_instances_for(reference_date)
          profile_bi                = fetch_profile_budget_instance_for(reference_date)

          # Then, recalculate the used amount for each category budget
          calculate_used_amount(profile_bi)
          category_budget_instances.each(&method(:calculate_used_amount))

          # Then, recalculate the limit of the profile budget, if it exists
          calculate_percentage_limit_amount(profile_bi, profile_bi)

          # Then, recalculate all the category budgets which have an absolute or percentage limit type
          category_budget_instances.each do |category_bi|
            calculate_percentage_limit_amount(category_bi, profile_bi)
          end

          # Lastly, recalculate the remainder category budget, if it exists
          calculate_remainder_limit_amount(category_budget_instances, profile_bi)

          # Now save everything
          profile_bi&.save!
          category_budget_instances.each(&:save!)
        end
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

    def calculate_percentage_limit_amount(budget_instance, profile_budget_instance)
      return unless budget_instance&.limit_type_percentage?

      profile_income    = calculate_profile_income(budget_instance.start_date, budget_instance.end_date)
      limit_reference   = profile_budget_instance&.limit_amount if budget_instance != profile_budget_instance
      limit_reference ||= profile_income

      budget_instance.limit_amount = limit_reference * (budget_instance.limit_percentage / 100.0)
    end

    def calculate_remainder_limit_amount(category_budget_instances, profile_budget_instance)
      remainder_bi = category_budget_instances.find(&:limit_type_remainder?)
      return unless remainder_bi

      categories_limit_amount = (category_budget_instances - [remainder_bi]).sum(&:limit_amount)
      profile_limit_amount    = profile_budget_instance&.limit_amount || calculate_profile_income(
        remainder_bi.start_date, remainder_bi.end_date
      )

      remainder_bi.limit_amount = [profile_limit_amount - categories_limit_amount, 0].max
    end

    def calculate_used_amount(budget_instance)
      return unless budget_instance

      transactions_in_period = transactions_in_period_for(budget_instance)

      transactions_sum            = transactions_in_period.sum(:amount_cents) * -1
      carryover_amount            = budget_instance.carryover_amount_from_last_month.to_f
      budget_instance.used_amount = Money.new(transactions_sum - carryover_amount, profile.currency_object)
    end

    def fetch_profile_budget_instance_for(reference_date)
      BudgetInstance.for_current_date(reference_date).find_by(profile: profile, owner: profile)
    end

    def fetch_category_budget_instances_for(reference_date)
      BudgetInstance.for_current_date(reference_date).where(profile: profile, owner_type: 'Category')
    end

    def transactions_in_period_for(budget_instance)
      transactions = profile.transactions.newer_than(budget_instance.start_date).older_than(budget_instance.end_date)
      return transactions unless budget_instance.owner.is_a?(Category)

      transactions.where(category: budget_instance.owner)
    end

    def parse_reference_dates
      Array.wrap(reference_dates).compact.map(&:beginning_of_month).uniq.sort
    end
  end
end
