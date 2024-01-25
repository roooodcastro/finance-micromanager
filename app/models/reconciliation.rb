# frozen_string_literal: true

class Reconciliation < ApplicationRecord
  monetize :difference_amount_cents, with_currency: ->(instance) { instance.currency }
  monetize :final_balance_amount_cents, with_currency: ->(instance) { instance.currency }

  belongs_to :profile
  belongs_to :balance_correction_transaction, class_name: 'Transaction', optional: true

  has_many :reconciliations_wallets, dependent: :destroy

  enum status: { in_progress: 'in_progress', finished: 'finished', cancelled: 'cancelled' }, _default: 'in_progress'

  validates :date, presence: true
  validates :status, presence: true

  validate :validate_no_in_progress_reconciliations
  validate :validate_date_not_before_other_reconciliation
  validate :validate_no_changes_after_finished
  validate :validate_no_changes_after_cancelled
  validate :validate_finish_date_in_future
  validate :validate_no_transaction_without_wallets

  def currency
    profile&.currency || Money.default_currency
  end

  def as_json(*)
    currency_as_json = difference_amount.currency.as_json(only: %w[name symbol iso_code])

    super.merge(
      reconciliations_wallets:      reconciliations_wallets.as_json,
      previous_reconciliation_date: previous_finished_reconciliation&.date,
      currency:                     currency_as_json
    )
  end

  def previous_finished_reconciliation
    profile.finished_reconciliations.select { |reconciliation| reconciliation.date < date }.first
  end

  def transactions
    @transactions ||= begin
      start_date = profile.latest_reconciliation&.date

      profile.transactions.joins(:category).where(categories: { category_type: 'user' }).then do |profile_transactions|
        profile_transactions = profile_transactions.newer_than(start_date + 1.day) if start_date
        profile_transactions.older_than(date)
      end
    end
  end

  private

  def validate_no_in_progress_reconciliations
    return if persisted? || profile.blank?
    return if profile.reconciliations.in_progress.where.not(id:).blank?

    errors.add(:base, :cannot_have_two_reconciliations_in_progress)
  end

  def validate_date_not_before_other_reconciliation
    return if profile.blank?
    return unless in_progress?
    return if profile.reconciliations.finished.where(date: [date...]).blank?

    errors.add(:date, :cannot_be_older_than_finished_reconciliations)
  end

  def validate_no_changes_after_finished
    return unless persisted?
    return if valid_status_change?('finished')
    return if changes.blank?

    errors.add(:base, :cannot_change_after_finished)
  end

  def validate_no_changes_after_cancelled
    return unless persisted?
    return if valid_status_change?('cancelled')
    return if changes.blank?

    errors.add(:base, :cannot_change_after_cancelled)
  end

  def validate_finish_date_in_future
    return unless finished?
    return if date <= Date.current

    errors.add(:date, :cannot_finish_date_in_future)
  end

  def validate_no_transaction_without_wallets
    return unless finished?
    return if transactions.all? { |transaction| transaction.wallet_id.present? }

    errors.add(:base, :cannot_have_transactions_with_no_wallets)
  end

  def valid_status_change?(status_to_check)
    (status_change&.last == status_to_check) ||
      (status != status_to_check && !status_change) || status_change&.first == 'in_progress'
  end
end
