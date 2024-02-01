# frozen_string_literal: true

module DataGenerator
  class Categories
    attr_reader :profile

    DEFAULT_CATEGORIES = [
      { name: 'Car', color: '#d9d9d9' },
      { name: 'Childcare', color: '#6fa8dc' },
      { name: 'Going Out', color: '#f1c232' },
      { name: 'Groceries', color: '#93c47d' },
      { name: 'Health', color: '#274e13' },
      { name: 'House', color: '#cc4125' },
      { name: 'Income', color: '#6aa84f' },
      { name: 'Subscriptions', color: '#45818e' },
      { name: 'Transportation', color: '#3d85c6' },
      { name: 'Travel', color: '#674ea7' },
      { name: 'Utilities', color: '#d0e0e3' }
    ].freeze

    def initialize(profile_id)
      @profile = Profile.find(profile_id)
    end

    def generate!
      DEFAULT_CATEGORIES.each do |category_attributes|
        profile.categories.find_or_create_by!(category_attributes)
      end
    end
  end
end
