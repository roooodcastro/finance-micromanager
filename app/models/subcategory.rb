# frozen_string_literal: true

class Subcategory < ApplicationRecord
  include Disableable

  belongs_to :category

  has_many :transactions, dependent: :restrict_with_exception

  validates :name, presence: true

  def as_json(*)
    super.merge(display_name:)
  end

  def display_name
    "#{category.name}/#{name}"
  end
end
