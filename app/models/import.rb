# frozen_string_literal: true

class Import < ApplicationRecord
  belongs_to :profile
  belongs_to :wallet

  has_many :transactions, dependent: :restrict_with_exception

  enum source: { ptsb: 'ptsb', n26: 'n26', revolut: 'revolut', sheets: 'sheets' }
  enum status: { in_progress: 'in_progress', finished: 'finished', cancelled: 'cancelled' }, _default: 'in_progress'

  validates :source, presence: true
end
