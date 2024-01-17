# frozen_string_literal: true

class CategorySearch < ApplicationSearch
  def search
    search_show_disabled
    search_show_system

    relation
  end

  def search_show_disabled
    return if query_params[:show_disabled].to_b

    @relation = relation.active
  end

  def search_show_system
    return if query_params[:show_system].to_b

    @relation = relation.user
  end
end
