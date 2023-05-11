# frozen_string_literal: true

class Category < ApplicationRecord
  HEX_COLOR_REGEX = /\A[[0-9][a-f]]{6}\z/i

  belongs_to :account

  has_many :transactions, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :color, format: { with: HEX_COLOR_REGEX }
end
