# frozen_string_literal: true

class Transaction < ApplicationRecord
  include CacheLatestUpdatedAt

  RECENT_TRANSACTIONS_COUNT = 10

  monetize :amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }

  attr_accessor :amount_type

  belongs_to :import, optional: true
  belongs_to :transaction_automation, optional: true
  belongs_to :profile
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  belongs_to :category
  belongs_to :subcategory, optional: true
  belongs_to :wallet, optional: true

  before_validation :process_amount_type
  before_save -> { update_balances!(:save) }
  before_destroy :check_reconciliation_date_before_destroy, prepend: true
  before_destroy -> { update_balances!(:destroy) }

  validates :name, :transaction_date, :amount, presence: true
  validate :validate_cannot_alter_prior_to_reconciliation
  validate :validate_category_is_enabled
  validate :validate_wallet_is_enabled

  scope :exclude_debits, -> { where('amount_cents > 0') }
  scope :exclude_credits, -> { where('amount_cents < 0') }
  scope :older_than, ->(date) { where(transaction_date: [..date]) }
  scope :newer_than, ->(date) { where(transaction_date: [date...]) }
  scope :sort_by_recent, -> { order(transaction_date: :desc, created_at: :desc) }

  def currency
    profile&.currency || Money.default_currency
  end

  def as_json(*)
    super(except: %w[created_at updated_at])
      .merge(
        'name'        => display_name,
        'amount'      => amount.to_f,
        'subcategory' => subcategory.as_json,
        'wallet'      => wallet.as_json,
        'category'    => category.as_json(include_subcategories: false)
      )
  end

  def display_name
    I18n.exists?(name) ? I18n.t(name) : name
  end

  def debit?
    amount_cents.negative?
  end

  def credit?
    amount_cents >= 0
  end

  private

  def process_amount_type
    self.amount *= -1 if amount_type.to_s.to_sym == :debit && amount.positive?
    self.amount *= -1 if amount_type.to_s.to_sym == :credit && amount.negative?
  end

  def transaction_date_after_latest_reconciliation?
    current_date_after = transaction_date.to_date > profile.latest_reconciliation.date
    return true if !persisted? && current_date_after

    persisted? && transaction_date_was.to_date > profile.latest_reconciliation.date && current_date_after
  end

  def validate_cannot_alter_prior_to_reconciliation
    return unless transaction_date && profile.latest_reconciliation
    return if transaction_date_after_latest_reconciliation?
    return if changes.except(*%w[name category_id subcategory_id updated_by_id]).blank?

    errors.add(:base, :cannot_alter_prior_to_reconciliation, date: I18n.l(profile.latest_reconciliation.date))
  end

  def check_reconciliation_date_before_destroy
    return unless profile.latest_reconciliation
    return if transaction_date.to_date > profile.latest_reconciliation.date

    errors.add(:base, :cannot_alter_prior_to_reconciliation, date: I18n.l(profile.latest_reconciliation.date))
    throw(:abort)
  end

  def update_balances!(operation)
    ::Transactions::UpdateAssociatedBalances.call(self, operation)
  end

  def validate_category_is_enabled
    return unless changes[:category_id]
    return if category.blank? || category.enabled?

    errors.add(:category_id, :must_be_enabled)
  end

  def validate_wallet_is_enabled
    return unless changes[:wallet_id]
    return if wallet.blank? || wallet.enabled?

    errors.add(:wallet_id, :must_be_enabled)
  end
end
