# frozen_string_literal: true

class ApplicationSearch
  attr_reader :relation, :query_params

  def initialize(relation, query_params)
    @relation     = relation
    @query_params = default_search_params.merge(query_params)
  end

  def search
    relation
  end

  private

  def default_search_params
    {}
  end
end
