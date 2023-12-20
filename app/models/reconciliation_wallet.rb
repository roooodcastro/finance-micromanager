# frozen_string_literal: true

class ReconciliationWallet < ApplicationRecord
  monetize :balance_amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }

  belongs_to :reconciliation
  belongs_to :wallet

  validates :wallet_id, uniqueness: { scope: :reconciliation_id }

  validate :validate_balance_amount_change

  def currency
    reconciliation&.currency || Money.default_currency
  end

  def as_json(*)
    {
      id:                id,
      reconciliation_id: reconciliation_id,
      wallet_id:         wallet_id,
      balance_amount:    balance_amount.to_f
    }
  end

  private

  def validate_balance_amount_change
    return unless reconciliation
    return if reconciliation.in_progress? || changes[:balance_amount_cents].blank?

    errors.add(:balance_amount_cents, :cannot_change_on_completed_reconciliation)
  end
end
