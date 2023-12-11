# frozen_string_literal: true

class Reconciliation < ApplicationRecord
  monetize :difference_amount_cents, with_currency: ->(instance) { instance.currency }
  monetize :final_balance_amount_cents, with_currency: ->(instance) { instance.currency }

  belongs_to :profile
  belongs_to :balance_correction_transaction, class_name: 'Transaction', optional: true

  enum status: { in_progress: 'in_progress', finished: 'finished', cancelled: 'cancelled' }, _default: 'in_progress'

  validates :date, presence: true
  validates :status, presence: true

  validate :validate_no_in_progress_reconciliations
  validate :validate_date_not_before_other_reconciliation
  validate :validate_no_changes_after_finished

  def currency
    profile&.currency || Money.default_currency
  end

  private

  def validate_no_in_progress_reconciliations
    return if persisted? || profile.blank?
    return if profile.reconciliations.in_progress.where.not(id:).blank?

    errors.add(:base, :cannot_have_two_reconciliations_in_progress)
  end

  def validate_date_not_before_other_reconciliation
    return if profile.blank?
    return if profile.reconciliations.finished.where(date: [date...]).blank?

    errors.add(:date, :cannot_be_older_than_finished_reconciliations)
  end

  def validate_no_changes_after_finished
    return unless persisted?
    return if !finished? || (finished? && status_change)
    return if changes.blank?

    errors.add(:base, :cannot_change_after_finished)
  end
end
