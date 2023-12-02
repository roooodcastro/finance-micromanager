# frozen_string_literal: true

class Subcategory < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :category
  belongs_to :disabled_by, class_name: 'User', optional: true

  has_many :transactions, dependent: :restrict_with_exception

  validates :name, presence: true

  scope :active, -> { where(disabled_at: nil) }
  scope :disabled, -> { where.not(disabled_at: nil) }

  def display_name
    "#{category.name}/#{name}"
  end

  def disable!
    update!(disabled_at: Time.current, disabled_by: Current.user)
  end

  def enable!
    update!(disabled_at: nil, disabled_by: nil)
  end
end
