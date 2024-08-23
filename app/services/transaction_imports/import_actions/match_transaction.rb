# frozen_string_literal: true

module TransactionImports
  module ImportActions
    class MatchTransaction < TransactionImports::ImportActions::Base
      def execute
        transaction = import_transaction.match_transaction
        return record_error(:cannot_find_transaction_to_match) if transaction.blank?

        transaction.attributes = import_transaction
                                 .attributes_for_transaction
                                 .slice(*%i[name transaction_date amount raw_import_name updated_by import_preview_id])
                                 .merge(import_id: import.id)

        return record_error(:invalid_transaction_to_match, error: transaction.error_messages) unless transaction.valid?

        transaction.save!

        statistics_recorder.record_transaction_matched(transaction)
      end
    end
  end
end
