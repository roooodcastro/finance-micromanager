# frozen_string_literal: true

module TransactionImports
  module ImportTransactionProcessors
    class DefaultActionSetter < BaseProcessor
      def call
        import_transactions.each do |import_transaction|
          update_action(import_transaction)
          clear_match_transaction(import_transaction)
          next unless import_transaction.match?

          match_data = top_match_data_for(import_transaction)
          import_transaction.assign_match_transaction(match_data&.dig(:transaction))
        end

        import_transactions
      end

      private

      def action_for(import_transaction)
        if import.minimum_transaction_date && import_transaction.transaction_date < import.minimum_transaction_date
          return :block
        end

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
        if transaction[:import_transaction_id].present? && transaction[:import_transaction_id] != import_transaction.id
          return
        end

        match_data
      end

      def update_action(import_transaction)
        new_action                     = action_for(import_transaction)
        import_transaction.has_changes = true if import_transaction.action != new_action
        import_transaction.action      = new_action
      end

      def clear_match_transaction(import_transaction)
        return if import_transaction.match?

        import_transaction.has_changes          = true if import_transaction.match_transaction_id.present?
        import_transaction.match_transaction_id = nil
      end
    end
  end
end
