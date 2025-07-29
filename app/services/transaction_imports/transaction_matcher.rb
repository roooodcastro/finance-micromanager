# frozen_string_literal: true

module TransactionImports
  class TransactionMatcher < ApplicationService
    attr_reader :import_transaction, :transactions, :matches

    # Maximum difference in days between two dates so they can be considered to have a half match
    DATE_MATCH_DAYS_THRESHOLD = 7
    # Maximum difference in currency cents units between two amounts so they can be considered to have a half match
    AMOUNT_MATCH_THRESHOLD    = 10
    # Minimum match score so that a transaction can be considered to match with this import transaction
    MATCH_SCORE_THRESHOLD     = 1.5

    def initialize(import_transaction, transactions)
      @import_transaction = import_transaction
      @transactions       = transactions
    end

    def call
      @matches   = transactions.each_with_object([]) do |transaction, result|
        match_data = match_data_for(transaction)
        result << match_data if match_data
      end

      @import_transaction.matches = matches.sort_by { |match| -match[:match_score] }
      @import_transaction
    end

    private

    def match_data_for(transaction)
      match_score      = match_score_for(transaction)
      return if match_score < MATCH_SCORE_THRESHOLD

      already_imported = transaction[:import_id].present?

      { transaction:, match_score:, already_imported: }
    end

    def match_score_for(transaction)
      name_match_score(transaction) + date_match_score(transaction) + amount_match_score(transaction)
    end

    def name_match_score(transaction)
      return 1 if transaction[:name] == import_transaction.name

      0
    end

    def date_match_score(transaction)
      return 0 unless import_transaction.transaction_date

      date_diff_days = (transaction[:transaction_date] - import_transaction.transaction_date).abs
      return 1 if date_diff_days.zero?
      return 0.5 if date_diff_days <= DATE_MATCH_DAYS_THRESHOLD

      0
    end

    def amount_match_score(transaction)
      return 1 if transaction[:amount_cents] == import_transaction.amount_cents
      return 0.5 if (transaction[:amount_cents] - import_transaction.amount_cents).abs < AMOUNT_MATCH_THRESHOLD

      0
    end
  end
end
