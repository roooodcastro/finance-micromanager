# frozen_string_literal: true

module StorePaginationOptions
  extend ActiveSupport::Concern

  COOKIE_NAME_ITEMS = 'PAGE_ITEMS'

  def current_pagination_items
    @current_pagination_items ||= cookies[COOKIE_NAME_ITEMS] = params[:items] || cookies[COOKIE_NAME_ITEMS]
  end
end
