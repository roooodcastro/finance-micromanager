# frozen_string_literal: true

class Budget < ApplicationRecord
  include Disableable

  monetize :limit_amount_cents, allow_nil: true, disable_validation: true,
    with_currency: ->(instance) { instance.currency }

  VALID_LIMIT_TYPES = {
    'Profile'  => %w[absolute percentage],
    'Category' => %w[absolute percentage remainder]
  }.freeze

  belongs_to :profile
  belongs_to :owner, polymorphic: true

  has_one :current_budget_instance, lambda {
    for_current_date
  }, class_name: 'BudgetInstance', inverse_of: :budget, dependent: :destroy

  has_many :budget_instances, dependent: :destroy

  validates :owner_id, uniqueness: { scope: :owner_type } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :owner_type, inclusion: { in: VALID_LIMIT_TYPES.keys }
  validates :limit_type, inclusion: { in: ->(instance) { VALID_LIMIT_TYPES[instance.owner_type] || [] } }
  validates :limit_amount, presence: true, if: ->(instance) { instance.limit_type_absolute? }
  validates :limit_amount, absence: true, unless: ->(instance) { instance.limit_type_absolute? }
  validates :limit_percentage, presence: true, if: ->(instance) { instance.limit_type_percentage? }
  validates :limit_percentage, absence: true, unless: ->(instance) { instance.limit_type_percentage? }
  validates :carryover, inclusion: { in: [true, false] }

  enum :limit_type, { absolute: 'absolute', percentage: 'percentage', remainder: 'remainder' }, prefix: :limit_type

  def self.build_budget(params)
    budget   = find_by(profile: Current.profile, owner_id: params[:owner_id]) if params[:owner_type] == 'Profile'
    budget ||= Current.profile.budgets.new
    budget.assign_attributes({ disabled_at: nil, disabled_by: nil }.merge(params))
    budget
  end

  def currency
    profile&.currency || Money.default_currency
  end

  def as_json
    super.merge('limit_amount' => limit_amount.to_f, 'formatted_limit' => formatted_limit)
  end

  def formatted_limit
    return if disabled?
    return I18n.t('activerecord.attributes.budget.limit_type_remainder') if limit_type_remainder?
    return limit_amount.format if limit_type_absolute?

    "#{limit_percentage}%"
  end
end
