# frozen_string_literal: true

class ImportNameSearch < ApplicationSearch
  def search
    search_search_string

    relation
  end

  def search_search_string
    return self if query_params[:search_string].blank?

    @relation = relation.where(
      'LOWER(import_name) like LOWER(:search) OR LOWER(transaction_name) like LOWER(:search)',
      search: "%#{query_params[:search_string]}%"
    )
    self
  end
end
