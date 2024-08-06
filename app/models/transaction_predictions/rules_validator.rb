# frozen_string_literal: true

module TransactionPredictions
  class RulesValidator
    attr_reader :rules_json

    OPERATOR_CONTAINS = 'contains'
    OPERATOR_EQUALS   = 'equals'
    OPERATORS         = [OPERATOR_CONTAINS, OPERATOR_EQUALS].freeze

    # rubocop:disable Layout/HashAlignment
    JSON_SCHEMA = {
      type: 'object',
      properties: {
        conditions: {
          type: 'array',
          minItems: 1,
          maxItems: 10,
          items: {
            type: 'object',
            properties: {
              operator: { type: 'string' },
              column: { type: 'string' },
              value: { type: 'string' }
            }
          }
        },
        actions: {
          type: 'array',
          minItems: 1,
          maxItems: 10,
          items: {
            type: 'object',
            properties: {
              column: { type: 'string' },
              value: { type: 'string' }
            }
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
