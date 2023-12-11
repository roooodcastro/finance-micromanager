# frozen_string_literal: true

class ReconciliationWallet < ApplicationRecord
  monetize :balance_amount_cents, with_currency: ->(instance) { instance.currency }

  belongs_to :reconciliation
  belongs_to :wallet

  def currency
    reconciliation&.currency || Money.default_currency
  end
end
