# frozen_string_literal: true

module CacheLatestUpdatedAt
  extend ActiveSupport::Concern

  included do
    after_commit lambda {
      Rails.cache.delete(self.class.latest_updated_at_cache_key(profile_id))
    }
  end

  class_methods do
    def latest_updated_at_cache_key(profile_id)
      "updated_at_#{name.underscore}_#{profile_id}"
    end

    def latest_updated_at
      return unless Current.profile

      Rails.cache.fetch(latest_updated_at_cache_key(Current.profile.id), expires_in: 1.week) do
        if defined?(override_db_latest_updated_at)
          override_db_latest_updated_at
        else
          where(profile: Current.profile).maximum(:updated_at)
        end
      end
    end
  end
end
