# frozen_string_literal: true

module TransactionImports
  class TransactionMatcher < ApplicationService
    attr_reader :import_transaction, :transactions, :matches

    # Maximum difference in days between two dates so they can be considered to have a half match
    DATE_MATCH_DAYS_THRESHOLD = 7
    # Maximum difference in currency units between two amounts so they can be considered to have a half match
    AMOUNT_MATCH_THRESHOLD    = 0.1
    # Minimum match score so that a transaction can be considered to match with this import transaction
    MATCH_SCORE_THRESHOLD     = 1.5

    DOUBLE_IMPORT_MATCH_SCORE = -1

    def initialize(import_transaction, transactions)
      @import_transaction = import_transaction
      @transactions       = transactions
    end

    def call
      @matches = transactions.each_with_object([]) do |transaction, result|
        match_data = match_data_for(transaction)
        next if match_data[:match_score] < MATCH_SCORE_THRESHOLD

        result << match_data
      end

      import_transaction.matches = matches.sort_by { |match| -match[:match_score] }
      import_transaction
    end

    private

    def match_data_for(transaction)
      match_score      = match_score_for(transaction)
      already_imported = transaction.import_id.present?

      { transaction:, match_score:, already_imported: }
    end

    def match_score_for(transaction)
      name_match_score(transaction) + date_match_score(transaction) + amount_match_score(transaction)
    end

    def name_match_score(transaction)
      return 1 if transaction.name == import_transaction.name

      0
    end

    def date_match_score(transaction)
      return 0 unless import_transaction.transaction_date
      return 1 if transaction.transaction_date.to_date == import_transaction.transaction_date.to_date

      date_diff_days = (transaction.transaction_date.to_date - import_transaction.transaction_date.to_date).abs
      return 0.5 if date_diff_days <= DATE_MATCH_DAYS_THRESHOLD

      0
    end

    def amount_match_score(transaction)
      return 1 if (transaction.amount.to_d - import_transaction.amount.to_d).abs < Float::EPSILON
      return 0.5 if (transaction.amount.to_d - import_transaction.amount.to_d).abs < AMOUNT_MATCH_THRESHOLD

      0
    end
  end
end
