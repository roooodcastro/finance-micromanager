# frozen_string_literal: true

class Transaction < ApplicationRecord
  RECENT_TRANSACTIONS_COUNT = 10

  monetize :amount_cents, disable_validation: true

  attr_accessor :amount_type

  belongs_to :import, optional: true
  belongs_to :wallet
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  belongs_to :category
  belongs_to :subcategory, optional: true

  before_validation :process_amount_type

  validates :name, :transaction_date, :amount, presence: true

  scope :exclude_debits, -> { where('amount_cents > 0') }
  scope :exclude_credits, -> { where('amount_cents < 0') }
  scope :older_than, ->(date) { where(transaction_date: [...date]) }
  scope :newer_than, ->(date) { where(transaction_date: [date...]) }
  scope :sort_by_recent, -> { order(transaction_date: :desc, created_at: :desc) }

  def as_json(*)
    super(except: %w[created_at updated_at], include: :category)
      .merge(amount_with_unit: amount.format, amount: amount.to_s)
  end

  def debit?
    amount_cents.negative?
  end

  def credit?
    amount_cents >= 0
  end

  private

  def process_amount_type
    self.amount *= -1 if amount_type.to_s.to_sym == :debit && amount.positive?
    self.amount *= -1 if amount_type.to_s.to_sym == :credit && amount.negative?
  end
end
