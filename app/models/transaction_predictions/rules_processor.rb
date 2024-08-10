# frozen_string_literal: true

module TransactionPredictions
  class RulesProcessor
    attr_reader :transaction_predictions

    def initialize(profile)
      @transaction_predictions = profile.transaction_predictions.active
    end

    def process_transaction(transaction, allowed_columns = nil)
      transaction_predictions.each do |prediction|
        rules = prediction.rules.rules_json
        next unless satisfy_conditions?(transaction, rules[:conditions])

        rules[:actions].map do |action|
          next if allowed_columns.present? && allowed_columns.exclude?(action[:column])

          transaction.public_send("#{action[:column]}=", action[:value])
        end
      end
    end

    private

    def satisfy_conditions?(transaction, conditions_hash)
      conditions_results = conditions_hash.map do |condition|
        field_value = transaction.public_send(condition[:column]).downcase

        if condition[:operator] == TransactionPredictions::RulesValidator::OPERATOR_CONTAINS
          field_value.include?(condition[:value].downcase)
        elsif condition[:operator] == TransactionPredictions::RulesValidator::OPERATOR_EQUALS
          field_value == condition[:value].downcase
        end
      end

      conditions_results.any?
    end
  end
end
