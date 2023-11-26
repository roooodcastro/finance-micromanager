# frozen_string_literal: true

class CategorySerializer < ApplicationSerializer
  attr_reader :start_date, :end_date

  def initialize(record, start_date: nil, end_date: nil)
    super(record)

    @start_date = start_date
    @end_date   = end_date
  end

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
      credit_amount: Money.new(credit_transactions.sum(&:amount)).format,
      debit_amount:  Money.new(debit_transactions.sum(&:amount)).format
    }
  end

  def transactions
    @transactions ||= begin
      scope = record.transactions.sort_by_recent
      scope = scope.older_than(Time.zone.parse(end_date)) if end_date
      scope = scope.newer_than(Time.zone.parse(start_date)) if start_date
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
