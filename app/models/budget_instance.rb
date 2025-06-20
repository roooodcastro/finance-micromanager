# frozen_string_literal: true

class BudgetInstance < ApplicationRecord
  monetize :limit_amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }
  monetize :used_amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }

  belongs_to :profile
  belongs_to :budget
  belongs_to :owner, polymorphic: true

  validates :owner_type, inclusion: { in: Budget::VALID_LIMIT_TYPES.keys }
  validates :limit_type, inclusion: { in: ->(instance) { Budget::VALID_LIMIT_TYPES[instance.owner_type] || [] } }
  validates :limit_amount, presence: true
  validates :limit_percentage, presence: true, if: ->(instance) { instance.limit_type_percentage? }
  validates :limit_percentage, absence: true, unless: ->(instance) { instance.limit_type_percentage? }
  validates :used_amount, presence: true

  enum :limit_type, { absolute: 'absolute', percentage: 'percentage', remainder: 'remainder' }, prefix: :limit_type

  scope :for_current_date, ->(date = Time.current) { where(start_date: ..date, end_date: date...) }

  def currency
    profile&.currency || Money.default_currency
  end

  def previous_instance
    @previous_instance ||= self.class.for_current_date(start_date - 1.day).find_by(profile_id:, budget_id:)
  end

  def next_instance
    @next_instance ||= self.class.for_current_date(end_date + 1.day).find_by(profile_id:, budget_id:)
  end

  def carryover_amount
    limit_amount - used_amount
  end
end
