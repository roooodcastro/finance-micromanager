# frozen_string_literal: true

class BudgetInstanceSearch
  attr_reader :relation, :query_params

  def initialize(relation, query_params)
    @relation     = relation
    @query_params = default_search_params.merge(query_params)
  end

  def search
    search_start_date
    search_end_date
    search_owner_type
    search_owner_id

    relation
  end

  # start_date here doesn't directly correlate to the start_date column. Rather, it means the start of a date range
  # that budget instances should be searched for, so which months should be returned.
  def search_start_date
    return self unless query_params.key?(:start_date)

    @relation = relation.where(start_date: query_params[:start_date]...)
    self
  end

  # end_date here doesn't correlate to the end_date column. Rather, it means the end of a date range that budget
  # instances should be searched for, so which months should be returned.
  def search_end_date
    return self unless query_params.key?(:end_date)

    @relation = relation.where(start_date: ..query_params[:end_date])
    self
  end

  def search_owner_type
    return self unless query_params.key?(:owner_type)

    @relation = relation.where(owner_type: query_params[:owner_type])
    self
  end

  def search_owner_id
    return self unless query_params.key?(:owner_id)

    @relation = relation.where(owner_id: query_params[:owner_id])
    self
  end

  def default_search_params
    {}
  end
end
