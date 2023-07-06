# frozen_string_literal: true

class TransactionSearch
  attr_reader :relation, :query_params

  def initialize(relation, query_params)
    @relation     = relation
    @query_params = default_search_params.merge(query_params)
  end

  def search
    search_exclude_debits
      .search_exclude_credits
      .search_days_to_show

    relation
  end

  def search_exclude_debits
    return self unless query_params.key?(:exclude_debits)
    return self unless ActiveRecord::Type::Boolean.new.deserialize(query_params[:exclude_debits])

    @relation = relation.exclude_debits
    self
  end

  def search_exclude_credits
    return self unless query_params.key?(:exclude_credits)
    return self unless ActiveRecord::Type::Boolean.new.deserialize(query_params[:exclude_credits])

    @relation = relation.exclude_credits
    self
  end

  def search_days_to_show
    return self if !query_params.key?(:days_to_show) || query_params[:days_to_show].to_i.zero?

    @relation = relation.newer_than(query_params[:days_to_show].to_i.days.ago)
    self
  end

  def default_search_params
    {
      days_to_show:    30,
      exclude_debits:  false,
      exclude_credits: false
    }
  end
end
