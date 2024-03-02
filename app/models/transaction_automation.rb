# frozen_string_literal: true

class TransactionAutomation < ApplicationRecord
  include Disableable

  monetize :transaction_amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }

  belongs_to :profile
  belongs_to :transaction_category, class_name: 'Category'
  belongs_to :transaction_subcategory, class_name: 'Subcategory', optional: true
  belongs_to :transaction_wallet, class_name: 'Wallet', optional: true

  has_many :transactions, dependent: :nullify

  validates :schedule_type, :scheduled_date, :transaction_name, :transaction_amount, presence: true
  validates :schedule_interval, numericality: { only_integer: true, greater_than: 0 }, unless: :schedule_type_custom?
  validates :schedule_interval, absence: true, if: :schedule_type_custom?
  validates :schedule_custom_rule, absence: true, unless: :schedule_type_custom?
  validates :schedule_custom_rule, inclusion: { in: -> { TransactionAutomations::CustomRule.available_rules } },
                                   if:        :schedule_type_custom?

  validate :validate_category_is_enabled
  validate :validate_wallet_is_enabled

  enum schedule_type: { month: 'M', week: 'W', day: 'D', custom: 'C' }, _prefix: :schedule_type

  def as_json
    super(except: %w[schedule_type transaction_amount_cents]).merge(
      schedule_type:           self.class.schedule_types[schedule_type],
      schedule_type_key:       schedule_type,
      transaction_amount:      transaction_amount.to_f,
      transaction_category:    transaction_category.as_json(include_subcategories: false),
      transaction_subcategory: transaction_subcategory.as_json,
      transaction_wallet:      transaction_wallet.as_json
    )
  end

  def currency
    profile&.currency || Money.default_currency
  end

  def bump_scheduled_date!
    return unless next_scheduled_date(scheduled_date)

    update!(scheduled_date: next_scheduled_date(scheduled_date))
  end

  def transaction_attributes
    {
      name:                      transaction_name,
      amount:                    transaction_amount,
      transaction_date:          scheduled_date,
      profile_id:                profile_id,
      category_id:               transaction_category_id,
      subcategory_id:            transaction_subcategory_id,
      wallet_id:                 transaction_wallet_id,
      transaction_automation_id: id,
      created_by_id:             profile.user_id,
      updated_by_id:             profile.user_id
    }
  end

  private

  def next_scheduled_date(current_date)
    return if !schedule_type_custom? && !schedule_duration

    return current_date + schedule_duration unless schedule_type_custom?

    custom_rule.next_scheduled_date(current_date)
  end

  def custom_rule
    @custom_rule ||= ::TransactionAutomations::CustomRule.new(self)
  end

  def schedule_duration
    return unless valid?
    return if schedule_type_custom?

    ActiveSupport::Duration.parse("P#{schedule_interval}#{self.class.schedule_types[schedule_type]}")
  end

  def validate_category_is_enabled
    return unless changes[:transaction_category_id]
    return if transaction_category.blank? || transaction_category.enabled?

    errors.add(:transaction_category_id, :must_be_enabled)
  end

  def validate_wallet_is_enabled
    return unless changes[:transaction_wallet_id]
    return if transaction_wallet.blank? || transaction_wallet.enabled?

    errors.add(:transaction_wallet_id, :must_be_enabled)
  end
end
