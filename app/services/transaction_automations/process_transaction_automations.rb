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
          Transaction.create!(transaction_automation.transaction_attributes)
          transaction_automation.bump_scheduled_date!
        end
      end
    end

    private

    def transaction_automations
      @transaction_automations ||= TransactionAutomation.active.where(scheduled_date: [..date])
    end
  end
end
