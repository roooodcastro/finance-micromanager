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
                                   .includes(:import_transaction)
                                   .newer_than(import.minimum_transaction_date)
                                   .where(wallet_id: import.wallet_id)
                                   .map do |t|
          {
            id:                    t.id,
            name:                  t.name,
            transaction_date:      t.transaction_date,
            amount_cents:          t.amount_cents,
            import_id:             t.import_id,
            category_id:           t.category_id,
            subcategory_id:        t.subcategory_id,
            import_transaction_id: t.import_transaction&.id
          }
        end
      end
    end
  end
end
