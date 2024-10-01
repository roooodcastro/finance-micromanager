# frozen_string_literal: true

module TransactionImports
  module ImportTransactionProcessors
    class DefaultActionSetter < BaseProcessor
      def call
        import_transactions.each do |import_transaction|
          # previous_action           = import_transaction.action
          import_transaction.action = action_for(import_transaction)
          next unless import_transaction.match?

          import_transaction.match_transaction = top_match_for(import_transaction)[:transaction]
          # import_transaction.save if previous_action == TransactionImports::ImportTransaction.actions[:import]
        end

        import_transactions
      end

      private

      def action_for(import_transaction)
        return :skip if import_transaction.skip?
        return :block if minimum_transaction_date && import_transaction.transaction_date < minimum_transaction_date

        top_match = top_match_for(import_transaction)
        return :import unless top_match
        return :skip if top_match[:already_imported]

        :match
      end

      def top_match_for(import_transaction)
        import_transaction.matches&.first
      end

      def minimum_transaction_date
        return unless import.profile.latest_reconciliation

        @minimum_transaction_date ||= import.profile.latest_reconciliation.date.to_date + 1.day
      end
    end
  end
end
