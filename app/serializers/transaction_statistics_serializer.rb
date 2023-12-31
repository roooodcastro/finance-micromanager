# frozen_string_literal: true

class TransactionStatisticsSerializer < ApplicationSerializer
  alias transactions record

  def as_json
    {
      daily_totals:,
      spends:,
      money_in:
    }
  end

  private

  def daily_totals
    daily_totals_transactions = transactions
                                .group(:transaction_date)
                                .reorder(:transaction_date)
                                .select(:transaction_date, 'sum(amount_cents) as amount_cents')
                                .to_a
                                .map { |t| { date: t.transaction_date, amount: t.amount.to_f } }
                                .index_by { |transaction| transaction[:date] }

    days_in_period.map { |day| { date: day, amount: daily_totals_transactions.dig(day, :amount) || 0 } }
  end

  def spends
    all_transactions.select(&:debit?).sum(&:amount).to_f
  end

  def money_in
    all_transactions.select(&:credit?).sum(&:amount).to_f
  end

  def all_transactions
    @all_transactions ||= transactions.to_a
  end

  def days_in_period
    (CurrentDateRange.start_date.to_date..CurrentDateRange.end_date.to_date).to_a
  end
end
