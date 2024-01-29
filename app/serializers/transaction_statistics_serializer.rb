# frozen_string_literal: true

class TransactionStatisticsSerializer < ApplicationSerializer
  def as_json
    {
      daily_totals:,
      spends:,
      money_in:,
      start_balance:,
      end_balance:
    }
  end

  private

  def daily_totals
    daily_totals_transactions = transactions
                                .group(:transaction_date, :profile_id)
                                .order(:transaction_date)
                                .select(:transaction_date, :profile_id, 'sum(amount_cents) as amount_cents')
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

  def start_balance
    @start_balance ||= begin
      transactions_for_start = Current.profile.transactions.where(transaction_date: (...CurrentDateRange.start_date))

      if last_reconciliation_before_start_date.present?
        transactions_for_start = transactions_for_start
                                 .where.not(transaction_date: (..last_reconciliation_before_start_date.date))
      end

      amount_from_transactions = Money.from_cents(transactions_for_start.sum(:amount_cents), Current.profile.currency)

      ((last_reconciliation_before_start_date&.final_balance_amount || 0) + amount_from_transactions).to_f
    end
  end

  def end_balance
    start_balance + all_transactions.sum(&:amount).to_f
  end

  def last_reconciliation_before_start_date
    @last_reconciliation_before_start_date ||= Current
                                               .profile
                                               .reconciliations
                                               .finished
                                               .where(date: (...CurrentDateRange.start_date))
                                               .last
  end

  def all_transactions
    @all_transactions ||= transactions.to_a
  end

  def days_in_period
    (CurrentDateRange.start_date.to_date..CurrentDateRange.end_date.to_date).to_a
  end

  def transactions
    record.search_date_range_only
  end
end
