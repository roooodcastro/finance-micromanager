# frozen_string_literal: true

class Transaction < ApplicationRecord
  RECENT_TRANSACTIONS_COUNT = 10

  monetize :amount_cents, disable_validation: true

  attr_accessor :amount_type

  belongs_to :import, optional: true
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

  scope :exclude_debits, -> { where('amount_cents > 0') }
  scope :exclude_credits, -> { where('amount_cents < 0') }
  scope :older_than, ->(date) { where(transaction_date: [...date]) }
  scope :newer_than, ->(date) { where(transaction_date: [date...]) }
  scope :sort_by_recent, -> { order(transaction_date: :desc, created_at: :desc) }

  def as_json(*)
    super(except: %w[created_at updated_at], include: :category)
      .merge(amount_with_unit: amount.format, amount: amount.to_s, subcategory: subcategory.as_json)
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
    return if changes.blank?

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
end
