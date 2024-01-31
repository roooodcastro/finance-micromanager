# frozen_string_literal: true

module TransactionPredictions
  class Rules
    attr_reader :rules_json

    def initialize(raw_rules_json)
      @raw_rules_json = raw_rules_json
      @rules_json     = JSON.parse(raw_rules_json).deep_symbolize_keys
    end
  end
end
