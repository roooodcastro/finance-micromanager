# frozen_string_literal: true

class Wallet < ApplicationRecord
  include Disableable

  monetize :balance_cents, disable_validation: true

  belongs_to :profile

  has_many :transactions, dependent: :restrict_with_exception

  validates :name, :balance, presence: true

  def as_json(*)
    currency_as_json = balance.currency.as_json(only: %w[name symbol iso_code])
    super.merge(balance: balance.to_f, currency: currency_as_json)
  end

  private

  def can_disable?
    return true if balance.to_f.zero?

    errors.add(:base, :cannot_disable_with_nonzero_balance)
    false
  end
end
