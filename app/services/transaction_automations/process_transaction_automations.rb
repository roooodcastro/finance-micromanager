# frozen_string_literal: true

module TransactionAutomations
  class ProcessTransactionAutomations < ApplicationService
    attr_reader :date

    def initialize(date)
      @date = date.to_date
    end

    def call
      transaction_automations.each do |transaction_automation|
        ActiveRecord::Base.transaction do
          Transaction.create!(transaction_automation.transaction_attributes) if transaction_automation.enabled?
          transaction_automation.bump_scheduled_date!
        end
      end
    end

    private

    def transaction_automations
      @transaction_automations ||= TransactionAutomation
                                   .where(scheduled_date: [..date])
                                   .or(automations_to_create_at_start_of_month)
                                   .or(automations_to_create_at_start_of_week)
    end

    def automations_to_create_at_start_of_week
      TransactionAutomation.where(schedule_type: :week, scheduled_date: date.all_week, create_at_start_of_period: true)
    end

    def automations_to_create_at_start_of_month
      TransactionAutomation.where(
        schedule_type:             :month,
        scheduled_date:            date.all_month,
        create_at_start_of_period: true
      )
    end
  end
end
