# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user

  has_many :transactions, dependent: :restrict_with_exception
  has_many :categories, dependent: :restrict_with_exception
  has_many :imports, dependent: :restrict_with_exception

  enum status: { active: 'active', disabled: 'disabled' }

  validates :status, presence: true
  validates :currency, presence: true, inclusion: { in: Money::Currency.map(&:id).map(&:to_s) }

  def as_json(*)
    super(except: %w[created_at updated_at]).merge(currencyObject: Money::Currency.find(currency))
  end
end
