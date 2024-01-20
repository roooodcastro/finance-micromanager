# frozen_string_literal: true

class CategorySerializer < ApplicationSerializer
  def as_json(include_summary: false)
    json = category_as_json
    json = json.merge(summary: summary_as_json, subcategories_summary: subcategories_summary_as_json) if include_summary

    json
  end

  private

  def category_as_json
    record.as_json.merge(
      profile:       record.profile.as_json,
      subcategories: record.subcategories.active.order(:name).as_json
    )
  end

  def summary_as_json
    {
      credit_amount: Money.new(credit_transactions.sum(&:amount)).format,
      debit_amount:  Money.new(debit_transactions.sum(&:amount)).format
    }
  end

  def subcategories_summary_as_json
    record.subcategories.active.each_with_object({}) do |subcategory, result|
      subcat_transactions = subcategories_transactions(subcategory.id)

      result[subcategory.id] = {
        income_amount:  subcat_transactions.select { |t| t.amount.to_f.positive? }.sum(&:amount).to_f,
        spends_amount:  subcat_transactions.select { |t| t.amount.to_f.negative? }.sum(&:amount).to_f,
        balance_amount: subcat_transactions.sum(&:amount).to_f
      }
    end
  end

  def subcategories_transactions(subcategory_id)
    transactions.select { |transaction| transaction.subcategory_id == subcategory_id }
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
end
