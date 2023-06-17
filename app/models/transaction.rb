# frozen_string_literal: true

class Transaction < ApplicationRecord
  monetize :amount_cents, disable_validation: true

  belongs_to :import, optional: true
  belongs_to :account
  belongs_to :category

  validates :name, :transaction_date, :amount, presence: true

  def as_json(*)
    super(except: %w[transaction_date created_at updated_at], include: :category)
      .merge(amount_with_unit: amount.format, amount: amount.to_s)
  end
end
