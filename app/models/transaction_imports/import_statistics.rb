# frozen_string_literal: true

module TransactionImports
  class ImportStatistics
    attr_reader :imported_transactions, :matched_transactions, :error_transactions

    def initialize
      @imported_transactions = []
      @matched_transactions  = []
      @error_transactions    = []
    end

    def as_json
      { imported_transactions: imported_transactions.as_json, matched_transactions: matched_transactions.as_json,
error_transactions: error_transactions.as_json }
    end

    def record_transaction_imported(transaction)
      @imported_transactions << transaction
    end

    def record_transaction_matched(transaction)
      @matched_transactions << transaction
    end

    def record_error(import_transaction, reason_i18n_key, i18n_attributes = {})
      @error_transactions << { import_transaction:, reason_i18n_key:, i18n_attributes: }
    end
  end
end
