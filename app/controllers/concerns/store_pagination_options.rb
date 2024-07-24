# frozen_string_literal: true

module StorePaginationOptions
  extend ActiveSupport::Concern

  COOKIE_NAME_LIMIT = 'PAGE_ITEMS'

  def current_pagination_limit
    @current_pagination_limit ||= cookies[COOKIE_NAME_LIMIT] = params[:limit] || cookies[COOKIE_NAME_LIMIT]
  end
end
