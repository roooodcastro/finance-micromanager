# frozen_string_literal: true

module Statistics
  class CategorySummaryQuery < ApplicationQuery
    bind :wallet_id, :uuid
    bind :category_ids, :uuid, array: true
    bind :start_date, :datetime
    bind :end_date, :datetime

    private

    def wrapper_class
      Statistics::CategorySummary
    end

    def base_query
      <<~SQL.squish
        SELECT
          t.category_id,
          t.wallet_id,
          t.amount_currency AS currency_name,
          SUM(CASE WHEN t.amount_cents > 0 THEN t.amount_cents ELSE 0 END) AS credit_sum_cents,
          SUM(CASE WHEN t.amount_cents < 0 THEN t.amount_cents ELSE 0 END) AS debit_sum_cents
        FROM transactions AS t
        WHERE wallet_id = @wallet_id
        #{category_ids_filter}
        #{start_date_filter}
        #{end_date_filter}
        GROUP BY t.category_id, t.wallet_id, t.amount_currency
      SQL
    end

    def category_ids_filter
      return '' unless category_ids

      'AND t.category_id = @category_ids'
    end

    def start_date_filter
      return '' unless start_date

      'AND t.transaction_date >= @start_date'
    end

    def end_date_filter
      return '' unless end_date

      'AND t.transaction_date < @end_date'
    end
  end
end
