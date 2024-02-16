# frozen_string_literal: true

module Statistics
  class CategorySummaryQuery < ApplicationQuery
    bind :profile_id, :uuid
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
          c.id AS category_id,
          t.subcategory_id AS subcategory_id,
          c.profile_id,
          w.currency AS currency_name,
          SUM(CASE WHEN t.amount_cents > 0 THEN t.amount_cents ELSE 0 END) AS credit_sum_cents,
          SUM(CASE WHEN t.amount_cents < 0 THEN t.amount_cents ELSE 0 END) AS debit_sum_cents
        FROM categories AS c
        INNER JOIN profiles AS w ON w.id = c.profile_id
        LEFT JOIN subcategories AS sc ON c.id = sc.category_id
        LEFT JOIN transactions AS t
          ON t.category_id = c.id AND (t.subcategory_id = sc.id OR t.subcategory_id IS NULL)
          #{start_date_condition} #{end_date_condition}
        WHERE c.profile_id = @profile_id
        #{category_ids_condition}
        GROUP BY c.id, t.subcategory_id, c.profile_id, w.currency
        ORDER BY c.name
      SQL
    end

    def category_ids_condition
      return '' unless category_ids

      'AND c.id = @category_ids'
    end

    def start_date_condition
      return '' unless start_date

      'AND t.transaction_date >= @start_date'
    end

    def end_date_condition
      return '' unless end_date

      'AND t.transaction_date <= @end_date'
    end
  end
end
