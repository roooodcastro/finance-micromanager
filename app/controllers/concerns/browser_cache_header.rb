# frozen_string_literal: true

module BrowserCacheHeader
  extend ActiveSupport::Concern

  included do
    after_action :set_browser_cache_headers
  end

  private

  def set_browser_cache_headers
    return unless Current.profile

    headers['BROWSER-CACHE-UPDATED-AT-VALUES'] = [
      "category=#{latest_category_updated_at.to_i}"
    ].join(', ')
  end

  def latest_category_updated_at
    [Current.profile.categories.maximum(:updated_at), Current.profile.subcategories.maximum(:updated_at)].compact.max
  end
end
