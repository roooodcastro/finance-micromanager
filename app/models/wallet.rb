# frozen_string_literal: true

class Wallet < ApplicationRecord
  include Disableable

  monetize :balance_cents, disable_validation: true

  belongs_to :profile

  has_many :transactions, dependent: :restrict_with_exception

  validates :name, :balance, presence: true
end
