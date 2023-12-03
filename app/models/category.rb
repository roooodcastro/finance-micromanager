# frozen_string_literal: true

class Category < ApplicationRecord
  self.implicit_order_column = :created_at

  HEX_COLOR_REGEX = /\A#[[0-9][a-f]]{6}\z/i
  TEMPORARY_NAME  = 'Temporary'
  TEMPORARY_COLOR = '#808080'

  belongs_to :wallet

  has_many :transactions, dependent: :restrict_with_exception
  has_many :subcategories, dependent: :restrict_with_exception

  # rubocop:disable Rails/InverseOf
  has_many :active_subcategories, -> { active }, class_name: 'Subcategory', dependent: :restrict_with_exception
  # rubocop:enable Rails/InverseOf

  validates :name, presence: true
  validates :color, format: { with: HEX_COLOR_REGEX }

  def self.temporary_category_for(wallet)
    find_by!(wallet: wallet, name: TEMPORARY_NAME)
  rescue ActiveRecord::RecordNotFound
    create!(wallet: wallet, name: TEMPORARY_NAME, color: TEMPORARY_COLOR)
  end

  def as_json(*)
    super.merge(subcategories: active_subcategories.as_json)
  end
end
