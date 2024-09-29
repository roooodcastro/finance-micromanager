# frozen_string_literal: true

module TransactionImports
  module Parsers
    class PTSB < BaseParser
      FIRST_TRANSACTION_ROW  = 13
      LAST_TRANSACTION_ROW   = -2
      TRANSACTION_NAME_REGEX = /([a-z][\w[*]&%$@-]*)\s*/i
      TRANSACTION_DATE_REGEX = %r{\d{2}/\d{2}}i

      def parse_file
        rows = read_file.then(&method(:filter_non_transaction_rows))
        rows.map do |row|
          original_import_name = row[2].scan(TRANSACTION_NAME_REGEX).join(' ')
          name                 = row[2].scan(TRANSACTION_NAME_REGEX).join(' ')
          transaction_date     = extract_date(row)
          amount               = row[3].to_f - row[4].to_f
          wallet               = import.wallet

          TransactionImports::ImportTransaction.new(
            import:, original_import_name:, name:, transaction_date:, amount:, wallet:
          )
        end
      end

      private

      def filter_non_transaction_rows(rows)
        rows[FIRST_TRANSACTION_ROW..LAST_TRANSACTION_ROW]
      end

      def read_file
        import.source_file.open { |f| Roo::Excel.new(f) }.entries
      end

      # The date in a PTSB transaction sometimes refers to the date it was processed, not the original transaction date.
      # Because of this, we try to extract the true date from the transaction description, which is not always possible
      # if the description is too long. If we can extract it from the description, we must also infer the year. We try
      # to infer from the current or last year to solve the edge case when the transaction is processed around the
      # beginning of the year, but the transaction is for a date from last year, for example Dec 29th / Jan 2nd.
      def extract_date(row)
        return Date.parse(row[0]) unless row[2].match(TRANSACTION_DATE_REGEX)

        statement_date = row[2].match(TRANSACTION_DATE_REGEX)[0]

        current_year_date = parse_date(statement_date, Date.current.year)
        last_year_date    = parse_date(statement_date, Date.current.year - 1)

        current_year_date > Date.current ? last_year_date : current_year_date
      end

      def parse_date(statement_date, year)
        date_parts = statement_date.split('/').reverse
        Date.parse(([year] + date_parts).join('-'))
      end

      def source
        'ptsb'
      end
    end
  end
end
