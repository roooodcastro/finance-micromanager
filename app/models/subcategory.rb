# frozen_string_literal: true

class Subcategory < ApplicationRecord
  include CacheLatestUpdatedAt
  include Disableable

  delegate :profile_id, to: :category

  belongs_to :category

  has_many :transactions, dependent: :restrict_with_exception

  validates :name, presence: true

  def self.override_db_latest_updated_at
    joins(:category).where(categories: { profile: Current.profile }).maximum(:updated_at)
  end

  def as_json(*)
    super.merge(display_name:)
  end

  def display_name
    "#{category.display_name}/#{name}"
  end

  def compose_category_id
    [category_id, id].join('|')
  end
end
