# frozen_string_literal: true

module Statistics
  class CategorySummary
    include ActiveModel::Model

    attr_accessor :category_id, :profile_id, :currency_name, :credit_sum_cents, :debit_sum_cents

    def credit_sum
      credit_money.to_f
    end

    def debit_sum
      debit_money.to_f
    end

    def formatted_credit_sum
      credit_money.format
    end

    def formatted_debit_sum
      debit_money.format
    end

    def as_json
      {
        id:            SecureRandom.uuid,
        credit_sum:    credit_sum,
        debit_sum:     debit_sum,
        currency:      currency_name,
        currency_code: currency.iso_code,
        category_id:   category_id,
        profile_id:    profile_id
      }
    end

    private

    def currency
      @currency ||= Money::Currency.find(currency_name)
    end

    def credit_money
      @credit_money ||= Money.new(credit_sum_cents, currency)
    end

    def debit_money
      @debit_money ||= Money.new(debit_sum_cents, currency)
    end
  end
end
