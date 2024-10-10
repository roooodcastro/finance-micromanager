# frozen_string_literal: true

module TransactionImports
  module ImportTransactionProcessors
    class DefaultActionSetter < BaseProcessor
      def call
        import_transactions.each do |import_transaction|
          import_transaction.action = action_for(import_transaction)
          clear_match_transaction(import_transaction)
          next unless import_transaction.match?

          match_data = top_match_data_for(import_transaction)
          import_transaction.assign_match_transaction(match_data&.dig(:transaction))
        end

        import_transactions
      end

      private

      def action_for(import_transaction)
        return :block if minimum_transaction_date && import_transaction.transaction_date < minimum_transaction_date
        return import_transaction.action if import_transaction.action.present?

        top_match_data = top_match_data_for(import_transaction)
        return :import unless top_match_data
        return :skip if top_match_data[:already_imported]

        :match
      end

      def top_match_data_for(import_transaction)
        match_data = import_transaction.matches&.first
        return if match_data.blank?

        transaction = match_data[:transaction]
        return if transaction.import_transaction.present? && transaction.import_transaction != import_transaction

        match_data
      end

      def minimum_transaction_date
        return unless import.profile.latest_reconciliation

        @minimum_transaction_date ||= import.profile.latest_reconciliation.date.to_date + 1.day
      end

      def clear_match_transaction(import_transaction)
        import_transaction.match_transaction = nil unless import_transaction.match?
      end
    end
  end
end
