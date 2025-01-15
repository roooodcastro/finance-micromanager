# frozen_string_literal: true

class BudgetInstance < ApplicationRecord
  monetize :limit_amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }
  monetize :used_amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }

  VALID_LIMIT_TYPES = {
    'Profile'  => %w[absolute percentage],
    'Category' => %w[absolute percentage remainder]
  }.freeze

  belongs_to :profile
  belongs_to :budget
  belongs_to :owner, polymorphic: true

  validates :owner_id, uniqueness: { scope: :owner_type } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :owner_type, inclusion: { in: VALID_LIMIT_TYPES.keys }
  validates :limit_type, inclusion: { in: ->(instance) { VALID_LIMIT_TYPES[instance.owner_type] || [] } }
  validates :limit_amount, presence: true, if: ->(instance) { instance.limit_type_absolute? }
  validates :limit_amount, absence: true, unless: ->(instance) { instance.limit_type_absolute? }
  validates :limit_percentage, presence: true, if: ->(instance) { instance.limit_type_percentage? }
  validates :limit_percentage, absence: true, unless: ->(instance) { instance.limit_type_percentage? }
  validates :used_amount, presence: true

  enum :limit_type, { absolute: 'absolute', percentage: 'percentage', remainder: 'remainder' }

  def currency
    profile&.currency || Money.default_currency
  end
end
