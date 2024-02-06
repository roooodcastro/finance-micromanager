# frozen_string_literal: true

module TransactionPredictions
  class Rules
    attr_reader :rules_json

    OPERATORS = %w[contains equals].freeze
    ACTIONS   = %w[fill].freeze

    # rubocop:disable Layout/HashAlignment
    JSON_SCHEMA = {
      type: 'object',
      properties: {
        conditions: {
          type: 'array',
          minItems: 1,
          maxItems: 1,
          items: {
            type: 'object',
            properties: {
              operator: { type: 'string' },
              column: { type: 'string' },
              value: { type: 'string' }
            }
          }
        },
        action: {
          type: 'object',
          properties: {
            action: { type: 'string' },
            column: { type: 'string' },
            value: { type: 'string' }
          }
        }
      }
    }.freeze
    # rubocop:enable Layout/HashAlignment

    def initialize(raw_rules_json)
      @raw_rules_json = raw_rules_json
      @rules_json     = JSON.parse(raw_rules_json).deep_symbolize_keys
    end

    def valid?
      JSON::Validator.validate(JSON_SCHEMA, rules_json, strict: true)
    end
  end
end
