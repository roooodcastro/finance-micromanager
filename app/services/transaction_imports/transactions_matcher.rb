# frozen_string_literal: true

module TransactionImports
  class TransactionsMatcher < ApplicationService
    attr_reader :import, :import_transactions

    def initialize(import, import_transactions)
      @import              = import
      @import_transactions = import_transactions
    end

    def call
      import_transactions.each do |import_transaction|
        TransactionImports::TransactionMatcher.call(import_transaction, transactions_to_match)
      end

      import_transactions
    end

    private

    # All "active" transactions for the profile, meaning all the transactions after the latest reconciliation date
    def transactions_to_match
      @transactions_to_match ||= import
                                 .profile
                                 .transactions
                                 .includes(:category, :subcategory, wallet: :profile)
                                 .newer_than(minimum_transaction_date)
                                 .where(wallet: import.wallet)
                                 .to_a
    end

    def minimum_transaction_date
      return unless import.profile.latest_reconciliation

      import.profile.latest_reconciliation.date.to_date + 1.day
    end
  end
end
