# frozen_string_literal: true

class Import < ApplicationRecord
  validates :source, presence: true

  has_many :transactions, dependent: :restrict_with_exception

  enum source: { ptsb: 'ptsb', n26: 'n26' }
end
