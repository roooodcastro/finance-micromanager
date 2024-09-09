# frozen_string_literal: true

module TransactionImports
  module Parsers
    class N26 < BaseParser
      FIRST_TRANSACTION_ROW = 1

      def parse_file
        rows = read_file.then(&method(:filter_non_transaction_rows))
        rows.map do |row|
          original_import_name = build_full_transaction_name(row)
          name                 = process_import_names(original_import_name)
          transaction_date     = Date.parse(row[0])
          amount               = row[5].to_f
          wallet               = import.wallet

          TransactionImports::ImportTransaction.new(
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

      def build_full_transaction_name(row)
        [row[1], row[2], row[4]].map { |part| part.to_s.gsub('-', '').strip.presence }.uniq.compact.join(' ')
      end

      def source
        'n26'
      end
    end
  end
end
