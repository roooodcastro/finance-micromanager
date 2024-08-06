# frozen_string_literal: true

class TransactionPrediction < ApplicationRecord
  include Disableable
  include CacheLatestUpdatedAt

  belongs_to :profile

  validates :name, :rules_json, presence: true
  validate :validate_rules

  def rules
    return if rules_json.blank?

    @rules ||= TransactionPredictions::RulesValidator.new(rules_json)
  end

  def rules_json=(value)
    super
    @rules = nil
  end

  private

  def validate_rules
    return if rules_json.blank? || rules.valid?

    errors.add(:rules_json, :invalid)
  end
end
