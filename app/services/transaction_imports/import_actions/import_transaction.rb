# frozen_string_literal: true

module TransactionImports
  module ImportActions
    class ImportTransaction < TransactionImports::ImportActions::Base
      def execute
        transaction = Current.profile.transactions.new(
          import_transaction.attributes_for_transaction.merge(created_by: Current.user, import_id: import.id)
        )

        return record_error(:invalid_transaction_to_import, error: transaction.error_messages) unless transaction.valid?

        transaction.save!

        statistics_recorder.record_transaction_imported(transaction)
      end
    end
  end
end
