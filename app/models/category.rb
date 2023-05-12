# frozen_string_literal: true

class Category < ApplicationRecord
  HEX_COLOR_REGEX = /\A[[0-9][a-f]]{6}\z/i
  TEMPORARY_NAME  = 'Temporary'
  TEMPORARY_COLOR = '808080'

  belongs_to :account

  has_many :transactions, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :color, format: { with: HEX_COLOR_REGEX }

  def self.temporary_category_for(account)
    find_by!(account: account, name: TEMPORARY_NAME)
  rescue ActiveRecord::RecordNotFound
    create!(account: account, name: TEMPORARY_NAME, color: TEMPORARY_COLOR)
  end
end
