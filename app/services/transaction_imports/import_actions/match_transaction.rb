# frozen_string_literal: true

module TransactionImports
  module ImportActions
    class MatchTransaction < TransactionImports::ImportActions::Base
      def execute
        transaction = find_transaction_to_match
        return record_error(:cannot_find_transaction_to_match) if transaction.blank?

        transaction.attributes = import_transaction
                                 .attributes_for_transaction
                                 .slice(*%i[name transaction_date amount raw_import_name updated_by import_preview_id])
                                 .merge(import_id: import.id)

        return record_error(:invalid_transaction_to_match, error: transaction.error_messages) unless transaction.valid?

        transaction.save!

        statistics_recorder.record_transaction_matched(transaction)
      end

      private

      def find_transaction_to_match
        parser.transactions_to_match.find do |transaction|
          transaction.id == import_transaction.match_transaction_id && transaction.import_preview_id.blank?
        end
      end
    end
  end
end
