# frozen_string_literal: true

class CategorySerializer < ApplicationSerializer
  def as_json(include_summary: false, include_recent_transactions: false)
    json = category_as_json
    json = json.merge(summary: summary_as_json) if include_summary
    json = json.merge(recent_transactions: recent_transactions_as_json) if include_recent_transactions

    json
  end

  private

  def category_as_json
    record.as_json(include: :wallet)
  end

  def summary_as_json
    {
      credit_amount: format_currency(record.transactions.exclude_debits.sum(:amount_cents)),
      debit_amount:  format_currency(record.transactions.exclude_credits.sum(:amount_cents) * -1)
    }
  end

  def recent_transactions_as_json
    record.transactions.recent.map(&:as_json)
  end

  def format_currency(cents)
    Money.from_cents(cents, record.wallet.currency_object).format
  end
end
