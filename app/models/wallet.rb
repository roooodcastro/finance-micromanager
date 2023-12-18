# frozen_string_literal: true

class Wallet < ApplicationRecord
  include Disableable

  monetize :balance_cents, disable_validation: true

  belongs_to :profile

  has_many :transactions, dependent: :restrict_with_exception

  validates :name, :balance, presence: true

  def as_json(*)
    currency_as_json = balance.currency.as_json(only: %w[name symbol])
    super.merge(balance: balance.to_f, balance_formatted: balance.format, currency: currency_as_json)
  end
end
