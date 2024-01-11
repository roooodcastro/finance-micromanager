# frozen_string_literal: true

class TransactionAutomation < ApplicationRecord
  include Disableable

  monetize :transaction_amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }

  belongs_to :profile
  belongs_to :transaction_category, class_name: 'Category'
  belongs_to :transaction_subcategory, class_name: 'Subcategory', optional: true
  belongs_to :transaction_wallet, class_name: 'Wallet', optional: true

  has_many :transactions, dependent: :nullify

  validates :schedule_type, :next_schedule_date, :transaction_name, :transaction_amount, presence: true
  validates :schedule_interval, numericality: { only_integer: true, greater_than: 0 }

  enum schedule_type: { month: 'M', week: 'W', day: 'D' }

  def as_json
    super(except: %w[schedule_type]).merge(
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

  def bump_next_schedule_date!
    return if disabled? || !schedule_duration

    update!(next_schedule_date: next_schedule_date + schedule_duration)
  end

  private

  def schedule_duration
    return unless valid?

    ActiveSupport::Duration.parse("P#{schedule_interval}#{self.class.schedule_types[schedule_type]}")
  end
end
