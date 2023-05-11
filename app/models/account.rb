# frozen_string_literal: true

class Account < ApplicationRecord
  has_many :transactions, dependent: :restrict_with_exception
  has_many :imports, dependent: :restrict_with_exception

  enum status: { active: 'active', disabled: 'disabled' }

  validates :status, presence: true
end
