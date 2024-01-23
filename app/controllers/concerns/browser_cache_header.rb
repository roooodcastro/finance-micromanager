# frozen_string_literal: true

module BrowserCacheHeader
  extend ActiveSupport::Concern

  included do
    after_action :set_browser_cache_headers

    helper_method :latest_updated_at_values
  end

  def latest_updated_at_values
    return unless Current.profile

    %W[
      category=#{latest_category_updated_at.to_i}
      wallet=#{latest_wallet_updated_at.to_i}
      categorySummary=#{latest_category_summary_updated_at.to_i}
      transaction=#{latest_transaction_updated_at.to_i}
    ].join(', ')
  end

  private

  def set_browser_cache_headers
    return unless Current.profile

    headers['BROWSER-CACHE-TIMESTAMP']         = Time.current.to_i
    headers['BROWSER-CACHE-UPDATED-AT-VALUES'] = latest_updated_at_values
  end

  def latest_category_updated_at
    @latest_category_updated_at ||= [
      Current.profile.categories.maximum(:updated_at),
      Current.profile.subcategories.maximum(:updated_at)
    ].compact.max
  end

  def latest_wallet_updated_at
    @latest_wallet_updated_at ||= Current.profile.wallets.maximum(:updated_at)
  end

  def latest_category_summary_updated_at
    @latest_category_summary_updated_at ||= [
      latest_category_updated_at,
      latest_transaction_updated_at
    ].compact.max
  end

  def latest_transaction_updated_at
    @latest_transaction_updated_at ||= Current.profile.transactions.maximum(:updated_at)
  end
end
