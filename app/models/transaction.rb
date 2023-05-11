# frozen_string_literal: true

class Transaction < ApplicationRecord
  monetize :amount_cents

  belongs_to :import, optional: true
  belongs_to :account
  belongs_to :category

  validates :name, :transaction_date, :amount, presence: true
end
