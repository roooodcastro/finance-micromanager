# frozen_string_literal: true

class ProfileSearch < ApplicationSearch
  def search
    search_show_disabled

    relation
  end

  def search_show_disabled
    return if query_params[:show_disabled].to_b

    @relation = relation.active
  end
end
