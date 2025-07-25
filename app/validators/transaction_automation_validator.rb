# frozen_string_literal: true

class TransactionAutomationValidator < ActiveModel::Validator
  def validate(record)
    validate_category_is_enabled(record)
    validate_wallet_is_enabled(record)
  end

  private

  def validate_category_is_enabled(record)
    return unless record.changes[:transaction_category_id]
    return if record.transaction_category.blank? || record.transaction_category.enabled?

    record.errors.add(:transaction_category_id, :must_be_enabled)
  end

  def validate_wallet_is_enabled(record)
    return unless record.changes[:transaction_wallet_id]
    return if record.transaction_wallet.blank? || record.transaction_wallet.enabled?

    record.errors.add(:transaction_wallet_id, :must_be_enabled)
  end
end
