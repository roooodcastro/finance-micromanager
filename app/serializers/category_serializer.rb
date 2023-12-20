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
    record.as_json.merge(profile: record.profile.as_json, subcategories: record.subcategories.active.as_json)
  end

  def summary_as_json
    {
      credit_amount: Money.new(credit_transactions.sum(&:amount)).format,
      debit_amount:  Money.new(debit_transactions.sum(&:amount)).format
    }
  end

  def transactions
    @transactions ||= begin
      scope = record.transactions.sort_by_recent
      scope = scope.older_than(CurrentDateRange.end_date)
      scope = scope.newer_than(CurrentDateRange.start_date)
      scope.to_a
    end
  end

  def debit_transactions
    transactions.select(&:debit?)
  end

  def credit_transactions
    transactions.select(&:credit?)
  end

  def recent_transactions_as_json
    transactions.first(Transaction::RECENT_TRANSACTIONS_COUNT).as_json
  end
end
