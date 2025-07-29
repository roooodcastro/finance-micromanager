# frozen_string_literal: true

module TransactionImports
  module ImportTransactionProcessors
    class TransactionsMatcher < BaseProcessor
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
                                   .includes(:category, :subcategory, :import_transaction, wallet: :profile)
                                   .newer_than(import.minimum_transaction_date)
                                   .where(wallet: import.wallet)
                                   .map do |t|
                                     t.attributes.symbolize_keys.merge(import_transaction_id: t.import_transaction&.id)
                                   end
      end
    end
  end
end
