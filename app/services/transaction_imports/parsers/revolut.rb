# frozen_string_literal: true

module TransactionImports
  module Parsers
    class Revolut < BaseParser
      FIRST_TRANSACTION_ROW = 1
      COMPLETED_STATE       = 'COMPLETED'
      TYPE_TRANSFER         = 'TRANSFER'

      def parse_file
        rows = read_file.then(&method(:filter_non_transaction_rows))
        rows.each_with_object([]) do |row, result|
          next unless row[8] == COMPLETED_STATE

          original_import_name = parse_transaction_name(row)
          name                 = original_import_name
          transaction_date     = Date.parse(row[2])
          amount               = row[5].to_f
          wallet               = import.wallet

          result << TransactionImports::ImportTransaction.new(
            import:, original_import_name:, name:, transaction_date:, amount:, wallet:
          )
        end
      end

      private

      def read_file
        CSV.parse(read_source_file)
      end

      def filter_non_transaction_rows(rows)
        rows[FIRST_TRANSACTION_ROW..]
      end

      def parse_transaction_name(row)
        return row[4] unless row[0] == TYPE_TRANSFER

        "Transfer #{ActiveSupport::Inflector.downcase_first(row[4])}"
      end

      def source
        'revolut'
      end
    end
  end
end
