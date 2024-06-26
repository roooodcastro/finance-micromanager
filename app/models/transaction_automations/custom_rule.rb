# frozen_string_literal: true

module TransactionAutomations
  class CustomRule
    attr_reader :transaction_automation

    delegate :schedule_custom_rule, to: :transaction_automation

    LAST_DAY_OF_MONTH           = 'last_day_of_month'
    FIRST_BUSINESS_DAY_OF_MONTH = 'first_business_day_of_month'
    LAST_BUSINESS_DAY_OF_MONTH  = 'last_business_day_of_month'

    def self.available_rules
      [LAST_DAY_OF_MONTH, FIRST_BUSINESS_DAY_OF_MONTH, LAST_BUSINESS_DAY_OF_MONTH]
    end

    def initialize(transaction_automation)
      @transaction_automation = transaction_automation
    end

    def next_scheduled_date(current_date)
      return next_last_day_of_month(current_date) if schedule_custom_rule == LAST_DAY_OF_MONTH
      return next_first_business_day_of_month(current_date) if schedule_custom_rule == FIRST_BUSINESS_DAY_OF_MONTH
      return next_last_business_day_of_month(current_date) if schedule_custom_rule == LAST_BUSINESS_DAY_OF_MONTH

      nil
    end

    private

    def next_last_day_of_month(current_date)
      (current_date + 1.month).end_of_month
    end

    def next_first_business_day_of_month(current_date)
      start_of_month = (current_date + 1.month).beginning_of_month
      start_of_month.on_weekday? ? start_of_month : start_of_month.next_weekday
    end

    def next_last_business_day_of_month(current_date)
      end_of_month = (current_date + 1.month).end_of_month
      end_of_month.on_weekday? ? end_of_month : end_of_month.prev_weekday
    end
  end
end
