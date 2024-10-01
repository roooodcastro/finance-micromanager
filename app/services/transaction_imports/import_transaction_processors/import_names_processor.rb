# frozen_string_literal: true

module TransactionImports
  module ImportTransactionProcessors
    class ImportNamesProcessor < BaseProcessor
      def call
        import_transactions.each(&method(:process_import_names))
      end

      private

      def process_import_names(import_transaction)
        import_name = import_names.find { |name| name.import_name == import_transaction.name }
        return unless import_name

        import_transaction.import_name_object = import_name
        return if import_transaction.original_import_name != import_transaction.name

        import_transaction.name = import_name.transaction_name
      end

      def import_names
        @import_names ||= import.profile.import_names.to_a
      end
    end
  end
end
