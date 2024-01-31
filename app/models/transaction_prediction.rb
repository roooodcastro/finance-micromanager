# frozen_string_literal: true

class TransactionPrediction < ApplicationRecord
  include Disableable
  include CacheLatestUpdatedAt

  belongs_to :profile

  validates :name, :rules_json, presence: true

  def rules
    return if rules_json.blank?

    @rules ||= TransactionPredictions::Rules.new(rules_json)
  end

  def rules_json=(value)
    super(value)
    @rules = nil
  end
end
