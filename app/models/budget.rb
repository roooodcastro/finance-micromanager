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

  validates :owner_id, uniqueness: true
  validates :owner_type, inclusion: { in: VALID_LIMIT_TYPES.keys }
  validates :limit_amount, presence: true, if: ->(instance) { instance.limit_type_absolute? }
  validates :limit_amount, absence: true, unless: ->(instance) { instance.limit_type_absolute? }
  validates :limit_percentage,
            presence:     true,
            numericality: { greater_than: 0, less_than_or_equal_to: 100, message: :valid_percentage },
            if:           ->(instance) { instance.limit_type_percentage? }
  validates :limit_percentage, absence: true, unless: ->(instance) { instance.limit_type_percentage? }
  validates :carryover, inclusion: { in: [true, false] }

  validate :validate_remainder_limit_type
  validate :validate_category_amount_not_greater_than_profile_amount,
           if: ->(instance) { instance.limit_type_absolute? && instance.owner_type == 'Category' }
  validate :validate_profile_amount_not_less_than_category_amount,
           if: ->(instance) { instance.limit_type_absolute? && instance.owner_type == 'Profile' }

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

  private

  def validate_remainder_limit_type
    return if changes[:limit_type].blank?
    return unless limit_type_remainder?

    if owner_type == 'Profile'
      errors.add(:limit_type, :cannot_be_remainder_on_profile_budget)
    else
      return unless profile.budgets.limit_type_remainder.where.not(id:).exists?

      errors.add(:limit_type, :only_one_remainder_category_budget_per_profile)
    end
  end

  def validate_category_amount_not_greater_than_profile_amount
    return if limit_amount.nil? || profile.nil?

    profile_budget = profile.budget
    return unless profile_budget&.limit_type_absolute?
    return if profile_budget.limit_amount >= limit_amount

    errors.add(:limit_amount, :cannot_be_greater_than_profile_budget)
  end

  def validate_profile_amount_not_less_than_category_amount
    return if limit_amount.nil? || profile.nil?

    highest_category_limit_amount_cents = profile.budgets.limit_type_absolute.maximum(:limit_amount_cents)
    return if highest_category_limit_amount_cents.nil?

    highest_category_limit_amount = Money.new(highest_category_limit_amount_cents, currency)
    return if limit_amount >= highest_category_limit_amount

    errors.add(:limit_amount, :cannot_be_less_than_category_budget)
  end
end
