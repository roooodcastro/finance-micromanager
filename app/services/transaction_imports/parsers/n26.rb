# frozen_string_literal: true

module TransactionImports
  module Parsers
    class N26 < BaseParser
      FIRST_TRANSACTION_ROW = 1

      def parse
        rows = CSV.parse(read_source_file).then(&method(:filter_non_transaction_rows))
        rows.map do |row|
          raw_name = build_full_transaction_name(row)
          name     = row[1]
          date     = Date.parse(row[0])
          amount   = row[5].to_f

          [raw_name, name, date, amount]
        end
      end

      private

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
