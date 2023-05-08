# frozen_string_literal: true

class Transaction < ApplicationRecord
  monetize :amount_cents

  belongs_to :import, optional: true

  validates :name, :transaction_date, presence: true
end
