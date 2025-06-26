# frozen_string_literal: true

class CreateHistoricalBudgetInstances
  attr_reader :budget, :start_date, :end_date

  def self.call(budget, start_date, end_date)
    new(budget, start_date, end_date).call
  end

  def initialize(budget, start_date, end_date)
    @budget     = budget
    @start_date = start_date
    @end_date   = end_date
  end

  def call
    build_start_dates.each do |start_date|
      Budgets::BudgetInstanceFactoryService.call(budget, start_date).save!
    end

    Budgets::UpdateProfileBudgetInstancesService.call(budget.profile, build_start_dates)
  end

  private

  def build_start_dates
    date_periods = []
    current_date = start_date

    while current_date < end_date
      date_periods << current_date.beginning_of_month
      current_date += 1.month
    end

    date_periods
  end
end
