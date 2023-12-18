# frozen_string_literal: true

class ReconciliationWallet < ApplicationRecord
  monetize :balance_amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }

  belongs_to :reconciliation
  belongs_to :wallet

  validates :wallet_id, uniqueness: { scope: :reconciliation_id }

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
end
