# frozen_string_literal: true

class Import < ApplicationRecord
  belongs_to :account

  has_many :transactions, dependent: :restrict_with_exception

  enum source: { ptsb: 'ptsb', n26: 'n26', sheets: 'sheets' }

  validates :source, presence: true
end
